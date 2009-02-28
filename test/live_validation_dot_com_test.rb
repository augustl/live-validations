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
    assert_json_output "Validate.Presence", "LiveValidation('post_title')"
  end
  
  def test_format
    Post.validates_format_of :title, :with => /ohai/
    assert_json_output "Validate.Format", "/ohai/"
  end
  
  def test_numericality
    Post.validates_numericality_of :age
    assert_json_output "Validate.Numericality"
  end

  def test_length_with_minimum
    Post.validates_length_of :title, :minimum => 10
    assert_json_output "Validate.Length", "minimum: 10"
  end
  
  def test_length_with_maximum
    Post.validates_length_of :title, :maximum => 10
    assert_json_output "Validate.Length", "maximum: 10"
  end
  
  def test_length_with_range
    Post.validates_length_of :title, :within => 10..20
    assert_json_output "Validate.Length", "minimum: 10", "maximum: 20"
  end
  
  def test_length_with_is
    Post.validates_length_of :title, :is => 20
    assert_json_output "Validate.Length", "is: 20"
  end
  
  def assert_json_output(*outputs)
    validator = LiveValidations.current_adapter.new(Post.new)
    outputs.each {|o| assert validator[:validators][0].include?(o) }
  end
end