class Cuba
  module Router 
    class ItemResource

      attr_reader :content

      def initialize(name, controller_name: nil, only: [], &block)
        @name = name
        @controller_name = controller_name
        @only = only
        @content = block_given? ? Container.load_routes(&block) : []
        (only & [:show, :update, :destroy]).each do |a_method|
          self.send(a_method)
        end
      end

      def name
        name_id.to_sym
      end

      def make_on(app)
        route_proc = Proc.new do |id|
          app.define_singleton_method(name_id) { URI.unescape(id) }
          @content.each do |route|
            route.make_on(app)
          end
        end
        app.send(:on, name, &route_proc)
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
        id.gsub(/ies$/, 'y').gsub(/s$/, '')
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
          post('edit', controller_method: :update)
          get('edit', controller_method: :edit)

        end
      end

      def destroy
        @content += Container.load_routes do
          delete('', controller_method: :destroy)
        end
      end


    end
  end
end