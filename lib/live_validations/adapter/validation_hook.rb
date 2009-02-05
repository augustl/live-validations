module LiveValidations
  class Adapter
    # The internal representation of each of the 'validates' blocks in the adapter implementation.
    class ValidationHook
      attr_reader :json, :tag_attributes, :callback, :adapter_instance
      def initialize(&block)
        reset_data
        @proc = block
      end
      
      def raw_json(json)
        recursively_merge_hash(@raw_json, json)
      end
      
      def raw_tag_attributes(attributes)
        recursively_merge_hash(@raw_tag_attributes, attributes.symbolize_keys)
      end
      
      def run_validation(adapter_instance, callback)
        @adapter_instance = adapter_instance
        @callback = callback
        
        @proc.call(self)
        
        @callback.options[:attributes].each do |attribute|
          unless @json.blank?
            prefix =  @adapter_instance.active_record_instance.class.name.downcase
            @adapter_instance.json_data["#{prefix}[#{attribute}]"].merge!(@json)
          end
          
          unless @raw_json.blank?
            recursively_merge_hash(@adapter_instance.json_data, @raw_json)
          end
          
          unless @tag_attributes.blank?
            @adapter_instance.tag_attributes_data[attribute].merge!(@tag_attributes)
          end
          
          unless @raw_tag_attributes.blank?
            recursively_merge_hash(@adapter_instance.tag_attributes_data, @raw_tag_attributes)
          end
        end
        
        reset_data
      end
      
      private
      
      def recursively_merge_hash(h1, h2)
        h1.merge!(h2) {|key, _old, _new| if _old.class == Hash then recursively_merge_hash(_old, _new) else _new end  }
      end
      
      def reset_data
        @json = {}
        @raw_json = {}
        @tag_attributes = {}
        @raw_tag_attributes = {}
      end
    end
  end
end