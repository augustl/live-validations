module LiveValidations
  # The base class of an adapter.
  class AdapterBase
    attr_reader :data, :active_record_instance, :rendered_attributes
    
    def initialize(active_record_instance)
      @active_record_instance = active_record_instance
      @rendered_attributes = []
      
      # Initialize the data hash with the 'setup' call from
      # the validator.
      @data = {}
      self.class.setup_proc.call(self)
    end
    
    def run_validations
      active_record_instance.validation_callbacks.each do |callback|
        next if !alters_tag_attributes? && !callback_has_visible_attributes?(callback)
        
        method = callback.options[:validation_method]
        validation_hook = self.class.validation_hooks[method]
        
        if validation_hook
          validation_hook.instance_exec(validation_hook, &self.class.setup_proc)
          validation_hook.run_validation(self, callback)
        end
      end
    end
    
    # Is called whenever a field helper is called (<%= f.foo %>).
    def renders_attribute(attribute)
      @rendered_attributes << attribute
    end
    
    # Tells the form builder wether or not the adapter will
    # alter tag attributes in the generated forms. Overrided
    # per-adapter.
    def alters_tag_attributes?
      false
    end
    
    def [](key)
      data[key]
    end
    
    def []=(key, value)
      data[key] = value
    end
    
    def self.validates(name, &block)
      self.validation_hooks[name] = ValidationHook.new(&block)
    end

    def self.renders_inline(&block)
      @inline_javascript_proc = block
    end
    
    def self.response(name, &block)
      self.validation_responses[name] = ValidationResponse.new(&block)
    end
    
    def self.setup(&block)
      @setup_proc = block
    end
    
    def self.form_for_options(&block)
      @form_for_options_proc = block
    end
    
    def render_inline_javascript
      self.class.inline_javascript_proc.call(self)
    end
    
    def utilizes_inline_javascript?
      self.class.inline_javascript_proc && !data.blank?
    end
    
    # The DOM prefix, e.g. "post" for Post. Used to reference DOM ids 
    # and DOM names, such as "post[title]" and "post_title".
    def prefix
      active_record_instance.class.name.underscore
    end

    def handle_form_for_options(options)
      self.class.form_for_options_proc.call(options) if self.class.form_for_options_proc
    end
    
    private
    
    def callback_has_visible_attributes?(callback)
      callback.options[:attributes] && callback.options[:attributes].any? {|attribute| rendered_attributes.include?(attribute)}
    end
    
    def self.validation_hooks
      @validation_hooks ||= {}
    end
    
    def self.validation_responses
      @validation_responses ||= {}
    end
    
    def self.inline_javascript_proc
      @inline_javascript_proc
    end
    
    def self.setup_proc
      @setup_proc
    end
    
    def self.form_for_options_proc
      @form_for_options_proc
    end
  end
end
