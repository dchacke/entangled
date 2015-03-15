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

      # The model for this controller. E.g. Taco for a TacosController
      def model
        controller_name.classify.constantize
      end

      # Grabs @tacos
      def collection
        instance_variable_get(:"@#{resources_name}")
      end

      # Grabs @taco
      def member
        instance_variable_get(:"@#{resource_name}")
      end

      # Infer channel from current path
      def channel
        request.path
      end

      # Close the connection to the DB so as to
      # not exceed the pool size. Otherwise, too many
      # connections will be leaked and the pool
      # will be exceeded
      def close_db_connection
        if ActiveRecord::Base.connection
          ActiveRecord::Base.connection.close
        end
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
                redis.subscribe channel do |on|
                  # Broadcast messages to all connected clients
                  on.message do |channel, message|
                    tubesock.send_data message
                  end

                  # Send message to whoever just subscribed
                  tubesock.send_data({
                    resources: collection
                  }.to_json)

                  close_db_connection
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
                redis.subscribe channel do |on|
                  # Broadcast messages to all connected clients
                  on.message do |channel, message|
                    tubesock.send_data message
                  end

                  # Send message to whoever just subscribed
                  tubesock.send_data({
                    resource: member
                  }.to_json)

                  close_db_connection
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

              close_db_connection
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

              close_db_connection
            end

          when 'destroy'
            tubesock.onmessage do |m|
              yield

              # Send resource that was just destroyed back to client
              if member
                tubesock.send_data({
                  resource: member
                }.to_json)
              end

              close_db_connection
            end

          # For every other controller action, simply wrap whatever is
          # yielded in the tubesock block to execute it in the context
          # of the socket. Other custom actions can be added through this
          else
            tubesock.onmessage do |m|
              yield

              close_db_connection
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
