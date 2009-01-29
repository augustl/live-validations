require File.join(File.dirname(__FILE__), "test_helper")

class ValidatiousTest < Test::Unit::TestCase
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
    validator = LiveValidations::Adapters::Validatious.new(Post.new)
    
    expected_json_data = {:title => {:class => "required"}}
    assert_equal expected_json_data, validator.tag_attributes_data
  end
  
  def test_html_attribute_output
    LiveValidations.use(LiveValidations::Adapters::Validatious)
    Post.validates_presence_of :title, :category
    
    get :new
    assert_response :success
    
    assert_select('input#post_title.required')
    assert_select('select#post_category.required')
    assert css_select('script[type=text/javascript]').empty?
  end
end