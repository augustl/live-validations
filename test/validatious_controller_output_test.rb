require File.join(File.dirname(__FILE__), "test_helper")

class ValidatiousControllerOutputTest < ActionController::TestCase
  def setup
    @controller = PostsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    
    reset_callbacks Post
  end
  
  def teardown
    restore_callbacks Post
  end
  
  def test_html_attribute_output
    LiveValidations.use(LiveValidations::Adapters::Validatious)
    Post.validates_presence_of :title, :category
    
    get :new
    assert_response :success
    
    assert_select('form.validate')
    assert_select('input#post_title.required')
    assert_select('select#post_category.required')
    assert css_select('script[type=text/javascript]').empty?
  end
end