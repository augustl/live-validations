module LiveValidations
  class Adapter
    # The internal representation of each of the 'validates' blocks in the adapter implementation.
    class ValidationHook
      attr_reader :json, :tag_attributes, :callback
      def initialize(&block)
        @json = {}
        @tag_attributes = {}
        @proc = block
      end
      
      def run_validation(adapter_instance, callback)
        @adapter_instance = adapter_instance
        @callback = callback
        
        @proc.call(self)
        
        @callback.options[:attributes].each do |attribute|
          @adapter_instance.json_data[attribute.to_s].merge!(@json) unless @json.blank?
          @adapter_instance.tag_attributes_data[attribute].merge!(@tag_attributes) unless @tag_attributes.blank?
        end
      end
    end
  end
end