require File.join(File.dirname(__FILE__), "test_helper")

class LiveValidationsDotComTest < ActiveSupport::TestCase
  def setup
    reset_callbacks Post
    LiveValidations.use(LiveValidations::Adapters::LivevalidationDotCom)
  end
  
  def teardown
    restore_callbacks Post
  end
  
  def test_presence
    Post.validates_presence_of :title
    assert_validators :title, "Presence"
  end
  
  def test_format
    Post.validates_format_of :title, :with => /ohai/
    assert_validators :title, "Format", :pattern => "/ohai/"
  end
  
  def test_numericality
    Post.validates_numericality_of :age
    assert_validators :age, "Numericality"
  end
  
  def test_length_with_minimum
    Post.validates_length_of :title, :minimum => 10
    assert_validators :title, "Length", :minimum => 10
  end
  
  def test_length_with_maximum
    Post.validates_length_of :title, :maximum => 10
    assert_validators :title, "Length", :maximum => 10
  end
  
  def test_length_with_range
    Post.validates_length_of :title, :within => 10..20
    assert_validators :title, "Length", :minimum => 10, :maximum => 20
  end
  
  def test_length_with_is
    Post.validates_length_of :title, :is => 20
    assert_validators :title, "Length", :is => 20
  end
  
  def assert_validators(attribute, expected_validator, json = {})
    validator = LiveValidations.current_adapter.new(Post.new)
    assert validator[:validators][attribute].has_key?(expected_validator), "The validator did not include `#{expected_validator}'."

    json.each do |key, value|
      assert_equal value, validator[:validators][attribute][expected_validator][key]
    end
  end
end