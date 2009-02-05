require File.join(File.dirname(__FILE__), "test_helper")

class GeneralAdapterTest < ActiveSupport::TestCase
  def test_supports_controller_hooks
    Rails::VERSION.instance_eval {
      remove_const('MAJOR')
      remove_const('MINOR')
      const_set('MAJOR', 1)
      const_set('MINOR', 2)
    }
    
    assert !LiveValidations::Adapter.supports_controller_hooks?
    
    Rails::VERSION.instance_eval {
      remove_const('MAJOR')
      remove_const('MINOR')
      const_set('MAJOR', 2)
      const_set('MINOR', 3)
    }
    
    assert LiveValidations::Adapter.supports_controller_hooks?
    
    Rails::VERSION.instance_eval {
      remove_const('MAJOR')
      remove_const('MINOR')
      const_set('MAJOR', 3)
      const_set('MINOR', 0)
    }
    
    assert LiveValidations::Adapter.supports_controller_hooks?
  end
end