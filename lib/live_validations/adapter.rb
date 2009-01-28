module LiveValidations
  # The base class of an adapter.
  class Adapter
    # The proc used to render the JSON (see render_json)
    cattr_accessor :json_proc
    # A hash of ValidationHook instances.
    cattr_accessor :validation_hooks
    
    # This module contains the methods expected to be called by the adapter implementations.
    extend AdapterMethods
    
    def initialize(active_record_instance)
      @active_record_instance = active_record_instance
      
      active_record_instance.validation_callbacks.each do |callback|
        method = callback.options[:validation_method]
        self.class.validation_hooks[method].run_validation(self, callback)
      end
    end
    attr_reader :active_record_instance
    
    # Called by the form builder, rendering the JSON (if the adapter utilizes this)
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
  end
end