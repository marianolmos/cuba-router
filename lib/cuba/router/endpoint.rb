class Cuba
  module Router 
    class Endpoint

      attr_reader :content

      def initialize(name, method: :get, controller_method: nil)
        @name = name
        @method = method
        @controller_method = controller_method
        @content = []
      end

      def name
        @name.to_s.downcase
      end

      def controller_method
        (@controller_method || name).to_s.downcase.to_sym
      end

      def apply?(fragments, request)
        if method_apply?(request)
          if name.empty?
            fragments.empty?
          elsif fragments.size == 1
            fragments.first == name# || name == '*'
          end
        end
      end

      def apply_to(route_info, fragments)
        fragments.shift unless name.empty?
        route_info[:controller_method] = controller_method
        route_info
      end

      def define_path_methods(controller, args={})
        method_name = (args[:method_name] || []) + ['path']
        method_name.unshift(name) unless name.empty?
        url = (args[:url] || []) + [name]
        define_method_to_controller(controller, args.merge(method_name: method_name, url: url))
      end

      private

      def method_apply?(request)
        request.request_method.downcase.to_sym == @method
      end

      def define_method_to_controller(controller, args)
        method_name = args[:method_name].compact.reject(&:empty?).join('_').to_sym
        url = args[:url].compact.reject(&:empty?).join('/')
        return if controller.respond_to?(method_name)
        #puts "defining: #{method_name} => (#{url})"
        controller.define_singleton_method(method_name) do |args={}|
          path = url
          args.each do |k,v|
            path = path.gsub(":#{k}", v.to_s)
          end
          path
        end
      end
    end
  end
end