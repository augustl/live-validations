require File.join(File.dirname(__FILE__), "test_helper")

class LiveValidationDotComControllerOutputTest < ActionController::TestCase
  def setup
    @controller = PostsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    
    LiveValidations.use(LiveValidations::Adapters::LivevalidationDotCom)
    
    reset_callbacks Post
  end
  
  def teardown
    restore_callbacks Post
  end
  
  def test_json_output
    Post.validates_presence_of :title, :message => "ohai"
    
    get :new
    assert_response :success
     
    assert_select 'script[type=text/javascript]'
    assert @response.body.include?(%{new LiveValidation('post_title');})
    assert @response.body.include?(%{Validate.Presence, {"failureMessage": "ohai"}})
  end
end