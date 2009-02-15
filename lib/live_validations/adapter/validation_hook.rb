module LiveValidations
  class Adapter
    # The internal representation of each of the 'validates' blocks in the adapter implementation.
    class ValidationHook
      attr_reader :json, :tag_attributes, :callback, :prefix, :adapter_instance
      
      def initialize(&block)
        @proc = block
      end

      def run_validation(adapter_instance, callback)
        @adapter_instance = adapter_instance
        @callback = callback
        reset_data
        
        @callback.options[:attributes].each {|attribute| @proc.call(self, attribute) }
        
        json.each do |attribute, rules|
          @adapter_instance.json["#{prefix}[#{attribute}]"].merge!(rules)
        end
        tag_attributes.each do |attribute, rules|
          @adapter_instance.tag_attributes[attribute.to_sym].merge!(rules)
        end
      end
      
      private
      
      def reset_data
        @json = Hash.new {|hash, key| hash[key] = {} }
        @tag_attributes = Hash.new {|hash, key| hash[key] = {} }
        
        @prefix = @adapter_instance.active_record_instance.class.name.downcase
      end
    end
  end
end