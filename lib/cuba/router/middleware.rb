class Cuba
  module Router 
    class Middleware
    
      def initialize(app, opts = {})
        @app, @opts = app, opts
      end
      
      def call(env)
        request = Rack::Request.new(env)
        serve_request(request)
        @app.call(env)
      end

      def serve_request(request)
        route_info = Finder.new(@app.settings[:routes]).find(request)
        if route_info
          module_names = route_info.delete(:module_names) || []
          controller_class = route_info.delete(:controller_class)
          controller_method = route_info.delete(:controller_method)
          request.env['route_info'] = {
            controller_class: module_names.join + controller_class.to_s,
            action: controller_method,
            route_ids: route_info
          }
        end
      end
    end
  end
end