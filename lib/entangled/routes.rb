module ActionDispatch::Routing
  class Mapper
    private
    def sockets_for(resource, options = {})
      @resources = resource.to_s.underscore.pluralize.to_sym
      @resource = resource.to_s.underscore.singularize.to_sym

      if options.any?
        if options[:only]
          if options[:only].is_a? Symbol
            send :"draw_#{options[:only]}"
          elsif options[:only].is_a? Array
            options[:only].each do |option|
              send :"draw_#{option}"
            end
          end
        elsif options[:except]
          if options[:except].is_a? Symbol
            (default_options - [options[:except]]).each do |option|
              send :"draw_#{option}"
            end
          elsif options[:except].is_a? Array
            (default_options - options[:except]).each do |option|
              send :"draw_#{option}"
            end
          end
        end
      else
        draw_all
      end
    end

    def default_options
      [:index, :create, :show, :destroy, :update]
    end

    def draw_all
      default_options.each do |option|
        send :"draw_#{option}"
      end
    end

    def draw_index
      get :"/#{@resources}", to: "#{@resources}#index", as: @resources
    end

    def draw_create
      get :"/#{@resources}/create", to: "#{@resources}#create", as: :"create_#{@resource}"
    end

    def draw_show
      get :"/#{@resources}/:id", to: "#{@resources}#show", as: @resource
    end

    def draw_destroy
      get :"/#{@resources}/:id/destroy", to: "#{@resources}#destroy", as: :"destroy_#{@resource}"
    end

    def draw_update
      get :"/#{@resources}/:id/update", to: "#{@resources}#update", as: :"update_#{@resource}"
    end
  end
end
