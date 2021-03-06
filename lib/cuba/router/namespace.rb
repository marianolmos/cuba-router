class Cuba
  module Router 
    class Namespace
      #include Matcheable

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

      def make_on(app)
        route_proc = Proc.new do
          app.with(module_names: ([ app.vars[:module_names] ] + [ module_name ]).compact.join('::')) do
            @content.each do |route|
              route.make_on(app)
            end
          end
        end
        app.send(:on, name, &route_proc)
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