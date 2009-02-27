require File.join(File.dirname(__FILE__), "test_helper")

class LiveValidationsDotComTest < ActiveSupport::TestCase
  def setup
    reset_callbacks Post
    LiveValidations.use(LiveValidations::Adapters::LivevalidationsDotCom)
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
  
  def assert_json_output(*outputs)
    validator = LiveValidations.current_adapter.new(Post.new)
    outputs.each {|o| assert validator.data['validators'][0].include?(o) }
  end
end