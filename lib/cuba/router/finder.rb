class Cuba
  module Router 
    class Finder

      DEFAULT_INFO = {
        module_names: [],
        controller_class: nil,
        controller_method: nil,
        id: nil
      }

      def initialize(routes)
        @routes = routes
      end

      def find(request, routes: @routes, fragments: nil)
        fragments = request.path.split("/").reject { |s| s.empty? } unless fragments
        route = nil
        route_info = {}
        begin
          route = find_route(request, routes, fragments)
          return nil unless route
          route_info = route.apply_to(route_info, fragments)
          routes = route.content
        end until route.kind_of?(Endpoint)
        route_info
      end

      private

      def find_route(request, routes, fragments)
        endpoints = routes.select { |route|
          route.kind_of?(Endpoint) && route.apply?(fragments, request)
        }
        return endpoints.first unless endpoints.empty?

        resources = routes.select { |route|
          route.kind_of?(Resource) && route.apply?(fragments, request)
        }
        return resources.first unless resources.empty?

        namespaces = routes.select { |route|
          route.kind_of?(Namespace) && route.apply?(fragments, request)
        }
        return namespaces.first unless namespaces.empty?

        item_resources = routes.select { |route|
          route.kind_of?(ItemResource) && route.apply?(fragments, request)
        }
        return item_resources.first unless item_resources.empty?

        nil
      end

    end
  end
end