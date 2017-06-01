class Cuba
  module Router 
    class ItemResource

      attr_reader :content

      def initialize(name, controller_name: nil, only: [], &block)
        @name = name
        @controller_name = controller_name
        @only = only
        @content = block_given? ? Container.load_routes(&block) : []
        (only & [:show, :update, :delete]).each do |a_method|
          self.send(a_method)
        end
      end

      def name
        '*'
      end

      def apply?(fragments, request)
        fragments.first
      end

      def apply_to(route_info, fragments)
        route_info[:id] = fragments.shift
        route_info[name_id.to_sym] = route_info[:id]
        route_info
      end

      def define_path_methods(controller, args={})
        method_name = (args[:method_name] || []) + [singular_name]
        url = (args[:url] || []) + [":#{name_id}"]
        content.each do |route|
          route.define_path_methods(controller, args.merge(method_name: method_name, url: url))
        end
      end

      private

      def name_id
        singular_name + '_id'
      end

      def singular_name
        id = @controller_name.gsub(/([A-Z])/, '_\1').downcase
        id[0] = ''
        id.gsub(/s$/, '')
      end

      def show
        @content += Container.load_routes do
          get('', controller_method: :show)
        end
      end

      def update
        @content += Container.load_routes do
          post('', controller_method: :update)
          put('', controller_method: :update)
          patch('', controller_method: :update)
          get('edit', controller_method: :edit)
        end
      end

      def delete
        @content += Container.load_routes do
          delete('')
        end
      end


    end
  end
end