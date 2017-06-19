class Cuba
  module Router 
    class Mount

      def initialize(name, &block)
        @name = name
        @block = block
      end

      def make_on(app)
        app.send(:on, @name.downcase.to_s) do
          app.instance_eval(&@block)
        end
      end

      def define_path_methods(controller, args={})
      end
    end
  end
end