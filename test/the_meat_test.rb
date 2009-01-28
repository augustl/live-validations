require File.join(File.dirname(__FILE__), "test_helper")

class TheMeatTest < Test::Unit::TestCase
  def test_render_json
    validator = LiveValidations.current_adapter.new(Post.new)
    
    expected_json_data = {"title" => {"required" => true}}
    assert_equal expected_json_data, validator.json_data
  end  
end