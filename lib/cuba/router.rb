require "cuba/router/version"
require "cuba/router/container"
require "cuba/router/namespace"
require "cuba/router/item_resource"
require "cuba/router/resource"
require "cuba/router/endpoint"
require "cuba/router/mount"

class Cuba
  module Router   
    module ClassMethods
      def on_routes(&block)
        settings[:routes] = Container.load_routes(&block)        
        define do
          settings[:routes].each do |route|
            route.define_path_methods(self)
          end
          settings[:routes].each do |route|
            route.make_on(self)
          end
        end
      end
    end

    def redirect_to(path)
      res.redirect path
    end
  end
end
