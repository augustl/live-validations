require File.join(File.dirname(__FILE__), "test_helper")

class GeneralAdapterTest < ActiveSupport::TestCase
  def test_supports_controller_hooks
    Rails.expects(:version).returns("2.2.999")
    assert !LiveValidations::Adapter.supports_controller_hooks?
    
    Rails.expects(:version).returns("2.3")
    assert LiveValidations::Adapter.supports_controller_hooks?
    
    Rails.expects(:version).returns("2.3.1")
    assert LiveValidations::Adapter.supports_controller_hooks?
    
    Rails.expects(:version).returns("3.0")
    assert LiveValidations::Adapter.supports_controller_hooks?
  end
end