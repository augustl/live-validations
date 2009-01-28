module LiveValidations
  class Adapter
    # The internal representation of each of the 'validates' blocks in the adapter implementation.
    class ValidationHook
      attr_reader :json, :callback
      def initialize(&block)
        @json = {}
        @proc = block
      end
      
      def run_validation(adapter_instance, callback)
        @adapter_instance = adapter_instance
        @callback = callback
        
        @proc.call(self)
        
        pass_json_hooks_to_adapter_instance
      end
      
      private

      # Adds stuff to the adapter instance's @json_data
      def pass_json_hooks_to_adapter_instance
        return if @json.blank?
        
        @callback.options[:attributes].each do |attribute|
          @adapter_instance.json_data[attribute.to_s].merge!(@json)
        end
      end
    end
  end
end