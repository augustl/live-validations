require File.join(File.dirname(__FILE__), "test_helper")

class ValidatiousTest < ActiveSupport::TestCase
  def setup
    reset_callbacks Post
  end
  
  def teardown
    restore_callbacks Post
  end
  
  def test_render_json
    Post.validates_presence_of :title
    validator = LiveValidations::Adapters::Validatious.new(Post.new)
    
    expected_json_data = {:title => {:class => "required"}}
    assert_equal expected_json_data, validator.tag_attributes_data
  end
end