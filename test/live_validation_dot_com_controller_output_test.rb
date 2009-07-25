require File.join(File.dirname(__FILE__), "test_helper")

class LiveValidationDotComControllerOutputTest < ActionController::TestCase
  def setup
    LiveValidations.use(LiveValidations::Adapters::LivevalidationDotCom)
    reset_database
    reset_callbacks Post
  end
  
  def teardown
    restore_callbacks Post
  end
  
  def test_json_output
    Post.validates_presence_of :title, :message => "ohai"
    
    render
     
    assert_html 'script[type=text/javascript]'
    assert rendered_view.include?(%{new LiveValidation('post_title', {});})
    assert rendered_view.include?(%{Validate.Presence, {"failureMessage":"ohai"}})
  end
end