class Cuba
  module Router 
    class ItemResource

      attr_reader :content

      def initialize(controller_name: nil, only: [], &block)
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

      private

      def name_id
        id = @controller_name.gsub(/([A-Z])/, '_\1').downcase
        id[0] = ''
        id + '_id'
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