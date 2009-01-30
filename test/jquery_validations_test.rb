require File.join(File.dirname(__FILE__), "test_helper")

class JqueryValidationsTest < Test::Unit::TestCase
  def setup
    @controller = PostsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    
    reset_callbacks Post
  end
  
  def teardown
    restore_callbacks Post
  end
  
  def test_render_json
    Post.validates_presence_of :title
    validator = LiveValidations::Adapters::JqueryValidations.new(Post.new)
    
    expected_json_data = {"post[title]" => {"required" => true}}
    assert_equal expected_json_data, validator.json_data
  end
  
  def test_json_output
    LiveValidations.use(LiveValidations::Adapters::JqueryValidations)
    Post.validates_presence_of :title
    
    get :new
    assert_response :success
            
    assert_select 'script[type=text/javascript]'
    assert @response.body.include?("$('#new_post').validate")
    assert @response.body.include?({'rules' => {'post[title]' => {'required' => true}}}.to_json)
  end
end