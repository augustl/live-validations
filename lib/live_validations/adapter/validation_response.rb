module LiveValidations
  class Adapter
    class ValidationResponse
      attr_reader :params
      def initialize(&block)
        @proc = block
      end
      
      def respond(params)
        @params = params

        return @proc.call(self)
      end
    end
  end
end