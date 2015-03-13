require 'tubesock'
require 'tubesock/hijack'

module Entangled
  module Controller
    include Tubesock::Hijack
    
    module InstanceMethods
      include Entangled::Helpers

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

      # Channel name for collection of resources, used in index
      # action
      def collection_channel
        model.channel
      end

      # The model for this controller. E.g. Taco for a TacosController
      def model
        controller_name.classify.constantize
      end

      # Channel name for single resource, used in show action
      def member_channel
        member.channel
      end

      def collection
        instance_variable_get(:"@#{resources_name}")
      end

      def member
        instance_variable_get(:"@#{resource_name}")
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
            if collection
              redis_thread = Thread.new do
                redis.subscribe collection_channel do |on|
                  # Broadcast messages to all connected clients
                  on.message do |channel, message|
                    tubesock.send_data message
                  end

                  # Send message to whoever just subscribed
                  tubesock.send_data({
                    resources: collection
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
            if member
              redis_thread = Thread.new do
                redis.subscribe member_channel do |on|
                  # Broadcast messages to all connected clients
                  on.message do |channel, message|
                    tubesock.send_data message
                  end

                  # Send message to whoever just subscribed
                  tubesock.send_data({
                    resource: member
                  }.to_json)
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
              params[resource_name.to_sym] = JSON.parse(m)
              yield

              # Send resource that was just created back to client. The resource
              # on the client will be overridden with this one. This is important
              # so that the id, created_at and updated_at and possibly other
              # attributes arrive on the client
              if member
                tubesock.send_data({
                  resource: member
                }.to_json)
              end
            end

          # If the controller's action name is 'update', a record should be
          # updated. Before yielding, the params hash has to be prepared
          # with attributes sent to the socket
          when 'update'
            tubesock.onmessage do |m|
              params[resource_name.to_sym] = JSON.parse(m)
              yield

              # Send resource that was just updated back to client. The resource
              # on the client will be overridden with this one. This is important
              # so that the new updated_at and possibly other attributes arrive
              # on the client
              if member
                tubesock.send_data({
                  resource: member
                }.to_json)
              end
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
      receiver.send :include, InstanceMethods
    end
  end
end
