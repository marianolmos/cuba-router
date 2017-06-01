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
            fragments.first == name || name == '*'
          end
        end
      end

      def apply_to(route_info, fragments)
        fragments.shift unless name.empty?
        route_info[:controller_method] = controller_method
        route_info
      end

      private

      def method_apply?(request)
        request.request_method.downcase.to_sym == @method
      end

      def to_s
        {class: self.class.to_s, name: name, controller_name: controller_name,  method: method}.to_s
      end
    end
  end
end