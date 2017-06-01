class Cuba
  module Router 
    class Namespace
      
      attr_reader :content

      def initialize(name, module_name: nil, &block)
        @name = name
        @module_name = module_name
        @content = block_given? ? Container.load_routes(&block) : []
      end

      def module_name
        @module_name || @name.to_s.split('-').map(&:capitalize).join
      end

      def name
        @name.to_s.downcase
      end

      def apply?(fragments, request)
        fragments.first == name
      end

      def apply_to(route_info, fragments)
        fragments.shift
        array = route_info[:module_names] || []
        array << module_name + '::'
        route_info[:module_names] = array
        route_info
      end

      def define_path_methods(controller, args={})
        method_name = (args[:method_name] || []) + [name]
        url = (args[:url] || []) + [name]
        content.each do |route|
          route.define_path_methods(controller, args.merge(method_name: method_name, url: url))
        end
      end

    end
  end
end