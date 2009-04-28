module LiveValidations
  class Adapter
    # The internal representation of each of the 'validates' blocks in the adapter implementation.
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
        reset_data
                
        # Call the proc once for each attribute in the callback. In the case of
        # "validates_format_of :foo, :bar, :baz, :with => /maz/", these attributes
        # will be [:foo, :bar, :baz].
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
      
      def setup
        yield(self)
      end
      
      # Returns a user specified validatior error message, or falls back to the default
      # I18n error message for the passed key.
      def message_for(key,options={})
        handwritten_message || I18n.translate(key, {:scope => 'activerecord.errors.messages'}.merge(options))
      end
      
      def handwritten_message
        return unless callback.options[:message]
        
        I18n.backend.send(:interpolate, I18n.locale, callback.options[:message], {
          :model => adapter_instance.active_record_instance.class.human_name
        })
      end
      
      # Returns the string that the validator should use as a regex in the javascripts.
      def format_regex
        callback.options[:live_validator] || callback.options[:with]
      end
      
      private
      
      def recursively_merge_hashes(h1, h2)
        h1.merge!(h2) {|key, _old, _new| if _old.class == Hash then recursively_merge_hashes(_old, _new) else _new end  }
      end
      
      def reset_data
        @prefix = @adapter_instance.prefix
      end
    end
  end
end