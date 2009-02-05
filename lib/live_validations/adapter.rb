module LiveValidations
  # The base class of an adapter.
  class Adapter
    # The proc used to render the JSON (see render_json)
    cattr_accessor :json_proc
    # A hash of ValidationHook instances.
    cattr_accessor :validation_hooks
    # A hash of ValidationResponse instances
    cattr_accessor :validation_responses
    
    # This module contains the methods expected to be called by the adapter implementations.
    extend AdapterMethods
    
    def initialize(active_record_instance)
      @active_record_instance = active_record_instance
      
      active_record_instance.validation_callbacks.each do |callback|
        method = callback.options[:validation_method]
        validation_hook = self.class.validation_hooks[method]
        
        if validation_hook
          validation_hook.run_validation(self, callback)
        end
      end
    end
    attr_reader :active_record_instance
    
    def self.supports_controller_hooks?
      Rails.version >= "2.3"
    end
    
    # Called by the form builder, rendering the JSON (if the adapter utilizes this)
    def render_json
      self.class.json_proc.call(self)
    end
    
    def utilizes_json?
      json_proc && !json_data.blank?
    end
    
    def json_data
      @json_data ||= hash_with_default_key {{}}
    end
    
    def tag_attributes_data
      @tag_attributes_data ||= hash_with_default_key {{}}
    end
    
    def extras
      @extras ||= hash_with_default_key {[]}
    end
    
    # Utility method, so that adapters can call this method directly instead of explicitly
    # doing what this method does -- converting the json_data to actual JSON data.
    def json
      json_data.to_json
    end
    
    private
    
    def hash_with_default_key
      Hash.new {|hash, key| hash[key] = yield }
    end
  end
end