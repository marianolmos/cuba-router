class Cuba
  module Router 
    class Mount

      def initialize(klass)
        @klass = klass
      end

      def make_on(app)
        app.run @klass
      end

      def define_path_methods(controller, args={})
      end
    end
  end
end