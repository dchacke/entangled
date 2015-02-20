require 'action_dispatch/routing'

module ActionDispatch::Routing
  class Mapper
    def sockets_for(resource, &block)
      resources = resource.to_s.underscore.pluralize.to_sym
      resource = resource.to_s.underscore.singularize.to_sym

      get :"/#{resources}", to: "#{resources}#index", as: resources
      get :"/#{resources}/create", to: "#{resources}#create", as: :"create_#{resource}"
      get :"/#{resources}/:id", to: "#{resources}#show", as: resource
      get :"/#{resources}/:id/destroy", to: "#{resources}#destroy", as: :"destroy_#{resource}"
      get :"/#{resources}/:id/update", to: "#{resources}#update", as: :"update_#{resource}"

      if block_given?
        namespace resources do
          yield
        end
      end
    end
  end
end
