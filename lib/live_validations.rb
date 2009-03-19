module LiveValidations
  class AdapterNotSpecified < StandardError; end
  class AdapterNotFound < StandardError; end
  class InvalidFormBuilderObject < ArgumentError; end
  
  # Set which adapter to use. Pass the adapter class directly. Example:
  #
  #  LiveValidation.use(LiveValidations::Adapters::JQueryValidations)
  def use(adapter_klass, options = {})
    @options = options.symbolize_keys
    
    case adapter_klass
    when String, Symbol
      adapter_name = "LiveValidations::Adapters::" + adapter_klass.to_s.camelize
      self.current_adapter = adapter_name.constantize
    when Class
      self.current_adapter = adapter_klass
    end
    
  rescue NameError => e
    raise AdapterNotFound, "The adapter `#{adapter_klass}' (#{adapter_name}) was not found."
  end
  
  def options
    @options
  end
  
  def current_adapter
    adapter = @current_adapter
    
    return adapter || raise(AdapterNotSpecified, "Please specify an adapter with `LiveValidations.use :adapter_name'.")
  end
  
  def current_adapter=(adapter)
    @current_adapter = adapter
  end
    
  extend self
end