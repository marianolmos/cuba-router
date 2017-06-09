class Cuba
  module Router 
    class Container

      def self.load_routes(&block)
        container = self.new().tap do |container|
          container.instance_eval(&block)
        end
        container.content
      end

      attr_reader :content

      def initialize(&block)
        @content = []
      end

      def namespace(name, module_name: nil, &block)
        @content << Namespace.new(name, module_name: module_name, &block)
      end

      def resource(name, controller_name: nil, only: [:index, :create, :update, :destroy, :show], &block)
        @content << Resource.new(name, controller_name: controller_name, only: only, &block)
      end

      def get(path= '', controller_method: nil)
        @content << Endpoint.new(path, method: :get, controller_method: controller_method)
      end

      def post(path= '', controller_method: nil)
        @content << Endpoint.new(path, method: :post, controller_method: controller_method)
      end

      def put(path= '', controller_method: nil)
        @content << Endpoint.new(path, method: :put, controller_method: controller_method)
      end

      def delete(path= '', controller_method: nil)
        @content << Endpoint.new(path, method: :delete, controller_method: controller_method)
      end

      def patch(path= '', controller_method: nil)
        @content << Endpoint.new(path, method: :patch, controller_method: controller_method)
      end

      def mount(klass_name)
        @content << Mount.new(klass_name)
      end

    end
  end
end