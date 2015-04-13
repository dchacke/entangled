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
      # resource on create and update. Furthermore,
      # keys are converted to camel case, to comply
      # with JavaScript conventions on the client
      def as_json(options = nil)
        super(options || attributes).merge(errors: errors).as_json.
          to_camelback_keys
      end

      # Build channels. Channels always at least include
      # a collection channel, i.e. /tacos, and a member
      # channel, i.e. /tacos/1, for direct access.
      # 
      # If the model belongs_to other models, nested channels
      # are created for all parents, grand parents, etc
      # recursively
      def channels(tail = '')
        channels = []

        # If the record is new, it should not have any channels
        return channels if new_record?

        plural_name = self.class.name.underscore.pluralize

        # Add collection channel for child only. If the tails
        # is not empty, the function is being called recursively
        # for one of the parents, for which only member channels
        # are needed
        if tail.empty?
          collection_channel = "/#{plural_name}" + tail
          channels << collection_channel
        end

        # Add member channel
        member_channel = "/#{plural_name}/#{to_param}" + tail
        channels << member_channel

        # Add nested channels for each parent
        parents.each do |parent|
          # Only recusively add collection channel
          # for child
          if tail.empty?
            channels << parent.channels(collection_channel)
          end

          channels << parent.channels(member_channel)
        end

        channels.flatten
      end

      private

      # Publishes to client. Whoever is subscribed
      # to the model's channels gets the message
      def publish(action)
        channels.each do |channel|
          redis.publish(channel, json(action))
        end
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

      # Find parent classes from belongs_to associations that
      # are not nil
      def parents
        self.class.
          reflect_on_all_associations(:belongs_to).
          map{ |a| send(a.name) }.
          reject(&:nil?)
      end
    end
    
    def self.included(receiver)
      receiver.extend         ClassMethods
      receiver.send :include, InstanceMethods
    end
  end
end
