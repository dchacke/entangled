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
      def channel
        name.underscore.pluralize
      end

      # Creates callbacks in the extented model
      def create_hook(name)
        send :"after_#{name}", -> { publish(name) }
      end
    end

    module InstanceMethods
      include Entangled::Helpers

      # Override the as_json method so that the
      # JSON representation of the resource includes
      # its errors. This is necessary so that errors
      # are sent back to the client along with the
      # resource on create and update
      def as_json(options = {})
        attributes.merge(errors: errors).as_json
      end

      # The inferred channel name for a single record
      # containing the inferred channel name from the class
      # and the record's id. For example, if it's a
      # DeliciousTaco with the id 1, the inferred channel
      # name for the single record is "delicious_tacos/1"
      def channel
        "#{self.class.channel}/#{self.to_param}"
      end

      private

      # Publishes to client. Whoever is subscribed
      # to the model's channel or the record's channel
      # gets the message
      def publish(action)
        redis.publish(
          self.class.channel,
          json(action)
        )

        redis.publish(
          channel,
          json(action)
        )
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
end
