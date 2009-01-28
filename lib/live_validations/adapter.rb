module LiveValidations
  # The base class of an adapter.
  class Adapter
    cattr_accessor :json_proc, :validation_hooks
    extend AdapterMethods
    
    attr_reader :active_record_instance

    def initialize(active_record_instance)
      @active_record_instance = active_record_instance
      iterate!
    end
    
    # Called by the form builder if JSON data is present for this validation.
    def render_json
      self.class.json_proc.call(self) if json_proc && !json_data.blank?
    end
    
    def json_data
      @json_data ||= Hash.new {|hash, key| hash[key] = {} }
    end
    
    # Utility method, so that adapters can call this method directly instead of explicitly
    # doing what this method does -- converting the json_data to actual JSON data.
    def json
      json_data.to_json
    end
    
    private

    def iterate!
      active_record_instance.validation_callbacks.each do |callback|
        method = callback.options[:validation_method]
        self.class.validation_hooks[method].run_validation(self, callback)
      end
    end
    
    # One of these are created for each of the 'validates' blocks in the adapter.
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