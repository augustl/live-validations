module LiveValidations
  class AdapterNotSpecified < StandardError; end
  
  # Set which adapter to use. Pass the adapter class directly. Example:
  #
  #  LiveValidation.use(LiveValidations::Adapters::JQueryValidations)
  def use(adapter_klass)
    self.current_adapter = adapter_klass
  end
  
  def current_adapter
    adapter = @_current_adapter
    
    return adapter || raise(AdapterNotSpecified, "Please specify an adapter with `LiveValidations.use(AdapterClassHere)'.")
  end
  
  def current_adapter=(adapter)
    @_current_adapter = adapter
  end
    
  extend self
end