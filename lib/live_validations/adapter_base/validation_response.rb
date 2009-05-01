module LiveValidations
  class AdapterBase
    # Currently this is used in the validates_uniqueness_of controller callback.
    class ValidationResponse
      attr_reader :params
      def initialize(&block)
        @proc = block
      end
      
      def respond(params)
        @params = params

        return @proc.call(self)
      rescue
        nil
      end
    end
  end
end