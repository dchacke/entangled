module ActionDispatch::Routing
  class Mapper
    private

    # Generates five routes that all use GET requests.
    # For example:
    # 
    #   sockets_for :messages
    # 
    # will create the following routes:
    # 
    #          Prefix Verb URI Pattern                     Controller#Action
    # create_messages GET  /messages/create(.:format)      messages#create
    #  update_message GET  /messages/:id/update(.:format)  messages#update
    # destroy_message GET  /messages/:id/destroy(.:format) messages#destroy
    #        messages GET  /messages(.:format)             messages#index
    #         message GET  /messages/:id(.:format)         messages#show
    # 
    # This method can nested by passing a block, and
    # the options :only and :except can be used just like
    # with the method 'resources'
    def sockets_for(*args, &block)
      options = args.extract_options!
      routes = infer_routes(options)
      resource_routes = infer_resource_routes(routes)

      # Generate index and show routes
      resources *args, only: resource_routes do
        # Generate create route
        collection do
          get 'create', as: :create if routes.include?(:create)
        end

        # Generate update and destroy routes
        member do
          get 'update', as: :update if routes.include?(:update)
          get 'destroy', as: :destroy if routes.include?(:destroy)
        end

        # Nest routes
        yield if block_given?
      end
    end

    def default_routes
      [:index, :create, :show, :destroy, :update]
    end

    # Find out which routes should be generated
    # inside resources method. These can be :create,
    # :update, and :destroy, and are the ones that
    # need to be overridden to use GET requests
    # instead of PATCH, POST and DELETE
    def infer_routes(options)
      if options.any?
        if options[:only]
          if options[:only].is_a?(Symbol)
            routes = [options[:only]]
          elsif options[:only].is_a?(Array)
            routes = options[:only]
          end
        elsif options[:except]
          if options[:except].is_a?(Symbol)
            routes = default_routes - [options[:except]]
          elsif options[:except].is_a?(Array)
            routes = default_routes - options[:except]
          end
        end
      else
        routes = default_routes
      end

      routes
    end

    # Find out if the resources method should create
    # :index and :show routes. These two do not need
    # to be overridden since they use GET requests
    # by default
    def infer_resource_routes(routes)
      resource_routes = []

      resource_routes << :index if routes.include?(:index)
      resource_routes << :show if routes.include?(:show)

      resource_routes
    end
  end
end
