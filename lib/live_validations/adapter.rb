module LiveValidations
  # The base class of an adapter.
  class Adapter
    
    attr_reader :json, :tag_attributes, :data, :messages, :active_record_instance
    
    def initialize(active_record_instance)
      @json             = Hash.new {|hash, key| hash[key] = {} }
      @tag_attributes   = Hash.new {|hash, key| hash[key] = {} }
      @data             = Hash.new {|hash, key| hash[key] = [] }
      @messages         = Hash.new {|hash, key| hash[key] = {} }
      @active_record_instance = active_record_instance
      
      active_record_instance.validation_callbacks.each do |callback|
        method = callback.options[:validation_method]
        validation_hook = self.class.validation_hooks[method]
        
        if validation_hook
          validation_hook.run_validation(self, callback)
        end
      end
    end
    
    def self.validates(name, &block)
      self.validation_hooks[name] = ValidationHook.new(&block)
    end

    def self.json(&block)
      @json_proc = block
    end
    
    def self.response(name, &block)
      self.validation_responses[name] = ValidationResponse.new(&block)
    end
    
    def self.form_for_options(&block)
      @form_for_options_proc = block
    end
    
    def render_json
      self.class.json_proc.call(self)
    end
    
    def utilizes_json?
      self.class.json_proc && (!json.blank? || !data.blank?)
    end

    def handle_form_for_options(options)
      options.merge!(:builder => LiveValidations::FormBuilder)
      self.class.form_for_options_proc.call(options) if self.class.form_for_options_proc
    end
    
    private
    
    def self.validation_hooks
      @validation_hooks ||= {}
    end
    
    def self.validation_responses
      @validation_responses ||= {}
    end
    
    def self.json_proc
      @json_proc
    end
    
    def self.form_for_options_proc
      @form_for_options_proc
    end
  end
end