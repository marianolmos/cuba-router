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
          settings[:routes].each do |route|
            route.define_path_methods(self)
          end

          route_info = env['route_info']

          on route_info do
            modules = self.class.to_s.split('::')
            klass = nil
            begin
              klass = Object.const_get(modules.join('::')).const_get(route_info[:controller_class])
            rescue NameError => e
            ensure
              modules.pop
            end until (modules.empty? || klass)
            raise StandardError.new("#{route_info[:controller_class]} Not found") unless klass
            # instancio el controller
            controller = klass.new

            # inyecto la app en la variable @app y redirecciono los metodos
            controller.instance_variable_set(:@app, self)
            controller.define_singleton_method(:method_missing) do |meth, *args, &blk|
              super(meth, *args, &blk) unless @app.respond_to?(meth)
              @app.send(meth, *args, &blk)
            end

            # brindo acceso a los params (string como clave)
            req.params.merge!(Hash[route_info[:route_ids].collect{|k,v| [k.to_s, URI.unescape(v)]}])
            controller.define_singleton_method(:params) { req.params }

            # ejecuto la accion deseada
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
