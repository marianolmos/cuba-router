class Cuba
  module Router 
    class Resource
      
      attr_reader :content

      def initialize(name, controller_name: nil, only: [], &block)
        @name = name
        @controller_name = controller_name
        @content = []
        (only & [:index, :create]).each do |a_method|
          self.send(a_method)
        end
        unless (only & [:show, :update, :delete]).empty?
          @content += [ ItemResource.new(self.name, controller_name: self.controller_name, only: only, &block) ]
        end
      end

      def name
        @name.to_s.downcase
      end

      def make_on(app)
        route_proc = Proc.new do
          app.with controller_name: controller_name do
            @content.each do |route|
              route.make_on(app)
            end
          end
        end
        app.send(:on, name, &route_proc)
      end

      def controller_name
        @controller_name || name.split('-').map(&:capitalize).join
      end

      def define_path_methods(controller, args={})
        method_name = (args[:method_name] || []) + [name]
        url = (args[:url] || []) + [name]
        content.each do |route|
          if route.kind_of?(ItemResource)
            route.define_path_methods(controller, args.merge(url: url))
          else
            route.define_path_methods(controller, args.merge(method_name: method_name, url: url))
          end
        end
      end

      private

      def index
        @content += Container.load_routes do
          get('', controller_method: :index)
        end
      end

      def create
        @content += Container.load_routes do
          get('new', controller_method: :new)
          post('', controller_method: :create)
          post('new', controller_method: :create)
        end
      end

    end
  end
end