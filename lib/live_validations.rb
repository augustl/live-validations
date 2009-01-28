module LiveValidations
  # Set which adapter to use. Pass the module itself. Example:
  #
  #  LiveValidation.use(LiveValidations::Adapters::JQueryValidations)
  def use(adapter_klass)
    self.current_adapter = adapter_klass
  end
  mattr_accessor :current_adapter
    
  extend self
end