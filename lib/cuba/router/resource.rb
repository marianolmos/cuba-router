class Cuba
  module Router 
    class Resource
      
      attr_reader :content

      def initialize(name, controller_name: nil, only: [], &block)
        @name = name
        @controller_name = controller_name
        @content = []
        unless (only & [:show, :update, :delete]).empty?
          @content += [ ItemResource.new(controller_name: self.controller_name, only: only, &block) ]
        end
        (only & [:index, :create]).each do |a_method|
          self.send(a_method)
        end
      end

      def name
        @name.to_s.downcase
      end

      def controller_name
        @controller_name || name.split('-').map(&:capitalize).join
      end

      def to_s
        {class: self.class.to_s, name: name, controller_name: controller_name, content: content.map(&:to_s)}.to_s
      end

      def apply?(fragments, request)
        name == fragments.first
      end

      def apply_to(route_info, fragments)
        fragments.shift
        route_info[:controller_class] = controller_name + 'Controller'
        route_info
      end

      private

      def index
        @content += Container.load_routes do
          get('', controller_method: :index)
        end
      end

      def create
        @content += Container.load_routes do
          post('', controller_method: :create)
          get('new', controller_method: :new)
        end
      end

    end
  end
end