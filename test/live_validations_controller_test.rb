require File.join(File.dirname(__FILE__), "test_helper")

require File.join(File.dirname(__FILE__), '..', 'app', 'controllers', 'live_validations_controller')
require File.join(File.dirname(__FILE__), '..', 'config', 'routes')

class LiveValidationsControllerOutputTest < ActionController::TestCase
  def setup
    @controller = LiveValidationsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    
    LiveValidations.use(LiveValidations::Adapters::JqueryValidations)
    reset_database
    reset_callbacks Post
  end
  
  def teardown
    restore_callbacks Post
  end
  
  def test_uniqueness_as_false
    Post.validates_uniqueness_of :title
    
    get :uniqueness, :model_class => 'Post', :post => {:title => 'something'}
    assert_response :success
    assert_equal 'true', @response.body
  end
  
  def test_uniqueness_as_true
    Post.validates_uniqueness_of :title
    Post.create!(:title => 'Unique? Who knows!')
    
    get :uniqueness, :model_class => 'Post', :post => {:title => 'Unique? Who knows!'}
    assert_response :success
    assert_equal 'false', @response.body
  end
end