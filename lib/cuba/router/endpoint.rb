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

      def make_on(app)
        return unless app.send(@method)
        route_proc = Proc.new do
          app.send(:with, controller_method: controller_method) do
            controller = make_controller(app)
            puts "Calling #{controller.class.to_s}##{controller_method}"
            controller.send(controller_method)
          end
        end
        if name.empty?
          app.send(:on, app.root, &route_proc)
        else
          app.send(:on, name, &route_proc)
        end
      end

      def controller_method
        (@controller_method || name).to_s.downcase.to_sym
      end

      def define_path_methods(controller, args={})
        method_name = (args[:method_name] || []) + ['path']
        method_name.unshift(name) unless name.empty?
        url = (args[:url] || []) + [name]
        define_method_to_controller(controller, args.merge(method_name: method_name, url: url))
      end

      private

      def get_class(app)
        original_modules = app.class.to_s.split('::')
        searched_klass = ([app.vars[:module_names]] + [app.vars[:controller_name] + 'Controller']).compact.join('::')
        klass = nil
        begin
          klass = Object.const_get(original_modules.join('::')).const_get(searched_klass)
        rescue NameError => e
        ensure
          original_modules.pop
        end until (original_modules.empty? || klass)
        raise StandardError.new("#{searched_klass} Not found") unless klass
        return klass
      end

      def make_controller(app)
        klass = get_class(app)
        controller = klass.new
        # inyecto la app en la variable @app y redirecciono los metodos
        controller.instance_variable_set(:@app, app)
        controller.define_singleton_method(:method_missing) do |meth, *args, &blk|
          super(meth, *args, &blk) unless @app.respond_to?(meth)
          @app.send(meth, *args, &blk)
        end
        controller
      end

      def define_method_to_controller(controller, args)
        method_name = args[:method_name].compact.reject(&:empty?).join('_').to_sym
        url = args[:url].compact.reject(&:empty?).join('/')
        return if controller.respond_to?(method_name)
        controller.define_singleton_method(method_name) do |args={}|
          path = url
          query_string = {}
          args.each do |k,v|
            if path.include? ":#{k}"
              path = path.gsub(":#{k}", v.to_s)
            else
              query_string[k.to_sym] = v
            end
          end
          path += "?#{ Rack::Utils.build_nested_query(query_string) }" unless query_string.empty?
          URI.escape('/' + path)
        end
      end
    end
  end
end