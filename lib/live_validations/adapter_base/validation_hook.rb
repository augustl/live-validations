module LiveValidations
  class AdapterBase
    # A ValidationHook is this plugins representation of a validation, and is created with
    # the adapter DSL through the Validations::AdapterBase.validates method.
    class ValidationHook
      attr_reader :data, :callback, :prefix, :adapter_instance
      
      def initialize(&block)
        @proc = block
        @data = {}
      end
      
      def [](key)
        data[key]
      end
      
      def []=(key, value)
        data[key] = value
      end

      def run_validation(adapter_instance, callback)
        @adapter_instance = adapter_instance
        @callback = callback
        @prefix = @adapter_instance.prefix
        
        # The @proc is called once for each of the attributes in the @callback,
        # passing the attribute to the proc much like validates_each.
        @callback.options[:attributes].each {|attribute| @proc.call(self, attribute) }
        

        @data.each do |key, value|
          case value
          when Hash
            recursively_merge_hashes(@adapter_instance[key], value)
          when Array
            @adapter_instance[key] += value
          end
        end
      end

      # Returns either the :message specified, or the default I18n error message.
      def message_for(attribute, key,options={})
        handwritten_message_for(attribute) || I18n.translate(key, {:scope => 'activerecord.errors.messages'}.merge(options))
      end
      
      def handwritten_message_for(attribute)
        return unless callback.options[:message]
        
        I18n.backend.send(:interpolate, I18n.locale, callback.options[:message], {
          :model => adapter_instance.active_record_instance.class.human_name,
          :attribute => attribute
        })
      end
      
      def regex
        callback.options[:live_validator] || callback.options[:with]
      end
      
      private
      
      def recursively_merge_hashes(h1, h2)
        h1.merge!(h2) {|key, _old, _new| if _old.class == Hash then recursively_merge_hashes(_old, _new) else _new end  }
      end
    end
  end
end