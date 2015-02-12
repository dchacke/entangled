require "entangled/version"
require 'tubesock'

module Entangled
	module Model
		module ClassMethods
			# Create after_ callbacks for options
			def entangle(options = {})

				# If :only is specified, the options can either
				# be an array or a symbol
				if options[:only].present?

					# If it is a symbol, something like only: :create
					# was passed in, and we need to create a hook
					# only for that one option
					if options[:only].is_a?(Symbol)
						create_hook options[:only]

					# If it is an array, something like only: [:create, :update]
					# was passed in, and we need to create hook for each
					# of these options
					elsif options[:only].is_a?(Array)
						options[:only].each { |option| create_hook option }
					end

				# Instead of :only, :except can be specified; similarly,
				# the options can either be an array or a symbol
				elsif options[:except].present?

					# If it is a symbol, it has to be taken out of the default
					# options. A callback has to be defined for each of the
					# remaining options
					if options[:except].is_a?(Symbol)
						(default_options - [options[:except]]).each do |option|
							create_hook option
						end

					# If it is an array, it also has to be taen out of the
					# default options. A callback then also has to be defined
					# for each of the remaining options
					elsif options[:except].is_a?(Array)
						(default_options - options[:except]).each do |option|
							create_hook option
						end
					end
				else

					# If neither :only nor :except is specified, simply create
					# a callback for each default option
					default_options.each { |option| create_hook option }
				end
			end

			# By default, model updates will be published after_create,
			# after_update, and after_destroy. This behavior can be
			# modified by passing :only or :except options to the
			# entangle class method
			def default_options
				[:create, :update, :destroy]
			end

			# The inferred channel name. For example, if the class name
			# is DeliciousTaco, the inferred channel name is "delicious_tacos"
			def inferred_channel_name
				name.underscore.pluralize
			end

			# Creates callbacks in the extented model
			def create_hook(name)
				send :"after_#{name}", proc { publish(name) }
			end
		end
		
		module InstanceMethods
			private

			# Publishes to client. Whoever is subscribed
			# to the model's channel or the record's channel
			# gets the message
			def publish(action)
				Redis.new.publish(
					self.class.inferred_channel_name,
					json(action)
				)

				Redis.new.publish(
					inferred_channel_name_for_single_record,
					json(action)
				)
			end

			# The inferred channel name for a single record
			# containing the inferred channel name from the class
			# and the record's id. For example, if it's a
			# DeliciousTaco with the id 1, the inferred channel
			# name for the single record is "delicious_tacos/1"
			def inferred_channel_name_for_single_record
				"#{self.class.inferred_channel_name}/#{id}"
			end

			# JSON containing the type of action (:create, :update
			# or :destroy) and the record itself. This is eventually
			# broadcast to the client
			def json(action)
				{
					action: action,
					resource: self
				}.to_json
			end
		end
		
		def self.included(receiver)
			receiver.extend         ClassMethods
			receiver.send :include, InstanceMethods
		end
	end
	
  module Controller
  	include Tubesock::Hijack

  	module ClassMethods
  		
  	end
  	
  	module InstanceMethods
  		private

  		# The plural name of the resource, inferred from the
  		# controller's name. For example, if it's the TacosController,
  		# the resources_name will be "tacos". This is used to
  		# infer the instance variable name for collections assigned
  		# in the controller action
  		def resources_name
  			controller_name
  		end

  		# The singular name of the resource, inferred from the
  		# resources_name. This is used to infer the instance
  		# variable name for a single record assigned in the controller
  		# action
  		def resource_name
  			resources_name.singularize
  		end

  		# Broadcast events to every connected client
  		def broadcast(&block)
  			# Use hijack to handle sockets
  			hijack do |tubesock|
  				# Assuming restful controllers, the behavior of
  				# this method has to change depending on the action
  				# it's being used in
  				case action_name

  				# If the controller action is 'index', a collection
  				# of records should be broadcast
  				when 'index'
  					yield

  					# The following code will run if an instance
  					# variable with the plural resource name has been
  					# assigned in yield. For example, if a
  					# TacosController's index action looked something
  					# like this:

  					# def index
  					#   broadcast do
  					#     @tacos = Taco.all
  					#   end
  					# end

  					# ...then @tacos will be broadcast to all connected
  					# clients. The variable name, in this example,
  					# has to be "@tacos"
  					if instance_variable_get(:"@#{resources_name}")
  						redis_thread = Thread.new do
  							Redis.new.subscribe resources_name do |on|
  								on.message do |channel, message|
  									tubesock.send_data message
  								end

  								# Broadcast collection to all connected clients
  								tubesock.send_data({
  									resources: instance_variable_get(:"@#{resources_name}")
  								}.to_json)
  							end
  						end

  						# When client disconnects, kill the thread
  						tubesock.onclose do
  							redis_thread.kill
  						end
  					end

  				# If the controller's action name is 'show', a single record
  				# should be broadcast
  				when 'show'
  					yield

  					# The following code will run if an instance variable
  					# with the singular resource name has been assigned in
  					# yield. For example, if a TacosController's show action
  					# looked something like this:

  					# def show
  					#   broadcast do
  					#     @taco = Taco.find(params[:id])
  					#   end
  					# end

  					# ...then @taco will be broadcast to all connected clients.
  					# The variable name, in this example, has to be "@taco"
  					if instance_variable_get(:"@#{resource_name}")
  						redis_thread = Thread.new do
  							Redis.new.subscribe "#{resources_name}/#{instance_variable_get(:"@#{resource_name}").id}" do |on|
  								on.message do |channel, message|
  									tubesock.send_data message
  								end

  								# Broadcast single resource to all connected clients
  								tubesock.send_data({ resource: instance_variable_get(:"@#{resource_name}") }.to_json)
  							end
  						end

  						# When client disconnects, kill the thread
  						tubesock.onclose do
  							redis_thread.kill
  						end
  					end

  				# If the controller's action name is 'create', a record should be
  				# created. Before yielding, the params hash has to be prepared
  				# with attributes sent to the socket. The actual publishing
  				# happens in the model's callback
  				when 'create'
  					tubesock.onmessage do |m|
  						params[resource_name.to_sym] = JSON.parse(m).symbolize_keys
  						yield
  					end

  				# If the controller's action name is 'update', a record should be
  				# updated. Before yielding, the params hash has to be prepared
  				# with attributes sent to the socket. The default attributes
  				# id, created_at, and updated_at should not be included in params.
  				when 'update'
  					tubesock.onmessage do |m|
  						params[resource_name.to_sym] = JSON.parse(m).except('id', 'created_at', 'updated_at', 'webSocketUrl').symbolize_keys
  						yield
  					end

  				# For every other controller action, simply wrap whatever is
  				# yielded in the tubesock block to execute it in the context
  				# of the socket. The delete action is automatically covered
  				# by this, and other custom action can be added through this.
  				else
  					tubesock.onmessage do |m|
  						yield
  					end
  				end
  			end
  		end
  	end
  	
  	def self.included(receiver)
  		receiver.extend         ClassMethods
  		receiver.send :include, InstanceMethods
  	end
  end
end
