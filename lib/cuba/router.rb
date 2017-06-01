require "cuba/router/version"
require "cuba/router/container"
require "cuba/router/namespace"
require "cuba/router/item_resource"
require "cuba/router/resource"
require "cuba/router/endpoint"
require "cuba/router/middleware"
require "cuba/router/finder"

class Cuba
  module Router
    
    module ClassMethods
      def on_routes(&block)
        settings[:routes] = Container.load_routes(&block)
        define do
          on env.env['route_info'] do
            route_info = env.env['route_info']
            modules = self.class.to_s.split('::')
            klass = nil
            begin
              klass = Object.const_get(modules.join('::')).const_get(route_info[:controller_class])
            rescue NameError => e
            ensure
              modules.pop
            end until (modules.empty? || klass)
            raise StandardError.new("#{route_info[:controller_class]} Not found") unless klass
            controller = klass.new
            controller.instance_variable_set(:@res, res)
            controller.define_singleton_method(:res) { @res }
            controller.instance_variable_set(:@request, env)
            controller.define_singleton_method(:request) { @request }
            route_info[:route_ids].each do |k, v|
              controller.define_singleton_method(k) { v }
            end
            settings[:routes].each do |route|
              route.define_path_methods(controller)
            end
            controller.send(route_info[:action])
          end
        
        end
      end
    end

    def setup(app)
      app.use Router::Middleware
    end
      
    module_function :setup

  end
end
