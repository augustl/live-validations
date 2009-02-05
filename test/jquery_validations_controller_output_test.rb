class JqueryValidationsControllerOutputTest < ActionController::TestCase
  def setup
    @controller = PostsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    
    reset_callbacks Post
  end
  
  def teardown
    restore_callbacks Post
  end
  
  def test_json_output
    Post.validates_presence_of :title
    
    get :new
    assert_response :success
            
    assert_select 'script[type=text/javascript]'
    assert @response.body.include?("$('#new_post').validate")
    assert @response.body.include?({'rules' => {'post[title]' => {'required' => true}}}.to_json)
  end
end