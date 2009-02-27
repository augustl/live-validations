module LiveValidations
  class Adapter
    # The internal representation of each of the 'validates' blocks in the adapter implementation.
    class ValidationHook
      attr_reader :json, :tag_attributes, :data, :messages, :callback, :prefix, :adapter_instance
      
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
        
        data.each do |key, contents|
          @adapter_instance.data[key] += contents
        end
        
        messages.each do |attribute, message|
          @adapter_instance.messages["#{prefix}[#{attribute}]"].merge!(message)
        end
      end
      
      # Returns a user specified validatior error message, or falls back to the default
      # I18n error message for the passed key.
      def message_for(key)
        callback.options[:message] || I18n.translate('activerecord.errors.messages')[key]
      end
      
      # Returns the string that the validator should use as a regex in the javascripts.
      def format_regex
        callback.options[:live_validator] || begin
          regex = callback.options[:with]
          js_regex = "/#{regex.source}/"
          js_regex << 'i' if regex.casefold?
          js_regex
        end
      end
      
      private
      
      def reset_data
        @json = Hash.new {|hash, key| hash[key] = {} }
        @tag_attributes = Hash.new {|hash, key| hash[key] = {} }
        @data = Hash.new {|hash, key| hash[key] = [] }
        @messages = Hash.new {|hash, key| hash[key] = {} }
        
        @prefix = @adapter_instance.active_record_instance.class.name.downcase
      end
    end
  end
end