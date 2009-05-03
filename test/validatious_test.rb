require File.join(File.dirname(__FILE__), "test_helper")

class ValidatiousTest < ActiveSupport::TestCase
  def setup
    reset_database
    reset_callbacks Post
    LiveValidations.use(LiveValidations::Adapters::Validatious)
  end
  
  def teardown
    restore_callbacks Post
  end
  
  def test_presence
    Post.validates_presence_of :title
    assert_expected_attributes_data :title => {:class => "required"}
  end
  
  def test_confirmation
    Post.validates_confirmation_of :password
    assert_expected_attributes_data :password_confirmation => {:class => "confirmation-of_post_password"}
  end
  
  def assert_expected_attributes_data(expected_attributes_data)
    validator = LiveValidations::Adapters::Validatious.new(Post.new)
    validator.run_validations
    
    assert_equal expected_attributes_data, validator[:tag_attributes]
  end
end