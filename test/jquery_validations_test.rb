require File.join(File.dirname(__FILE__), "test_helper")

LiveValidations.use(LiveValidations::Adapters::JqueryValidations)

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
    Post.validates_presence_of :title
    
    get :new
    assert_response :success
            
    assert_select 'script[type=text/javascript]'
    assert @response.body.include?("$('#new_post').validate")
    assert @response.body.include?({'rules' => {'post[title]' => {'required' => true}}}.to_json)
  end
  
  def test_confirmation
    Post.validates_confirmation_of :password
    validator = LiveValidations::Adapters::JqueryValidations.new(Post.new)
  
    expected_json = {"post[password_confirmation]" => {"equalTo" => "#post_password"}}
    assert_equal expected_json, validator.json_data
  end
  
  def test_validates_format_of_without_custom_javascript_format
    Post.validates_format_of :title, :with => /^[a-z0-9]+$/
    validator = LiveValidations::Adapters::JqueryValidations.new(Post.new)
    
    custom_validator_key = validator.render_json[/jQuery\.validator\.addMethod\('([a-f0-9]+)/, 1]
    expected_json = {"post[title]" => {custom_validator_key => true}}
    assert_equal expected_json, validator.json_data
  end
  
  def test_validates_format_of_with_custom_javascript_format
    Post.validates_format_of :title, :with => /^some odd ruby specific thing$/, :live_validator => '[a-z0-9]'
    validator = LiveValidations::Adapters::JqueryValidations.new(Post.new)
    
    assert validator.render_json.include?("[a-z0-9]")
    assert !validator.render_json.include?('some odd ruby specific thing')
    
    custom_validator_key = validator.render_json[/jQuery\.validator\.addMethod\('([a-f0-9]+)/, 1]
    expected_json = {"post[title]" => {custom_validator_key => true}}
    assert_equal expected_json, validator.json_data
  end

  def test_validates_acceptance_of
    Post.validates_acceptance_of :check_me
    validator = LiveValidations::Adapters::JqueryValidations.new(Post.new)
    
    expected_json = {"post[check_me]" => {"required" => true}}
    assert_equal expected_json, validator.json_data
  end
  
  def test_validates_length_of_within
    Post.validates_length_of :title, :within => 4..40
    validator = LiveValidations::Adapters::JqueryValidations.new(Post.new)
    
    expected_json = {"post[title]" => {"rangelength" => [4, 40]}}
    assert_equal expected_json, validator.json_data
  end
  
  def test_validates_length_of_maximum
    Post.validates_length_of :title, :maximum => 20
    validator = LiveValidations::Adapters::JqueryValidations.new(Post.new)
    
    expected_json = {"post[title]" => {"maxlength" => 20}}
    assert_equal expected_json, validator.json_data
  end
  
  def test_validates_length_of_minimum
    Post.validates_length_of :title, :minimum => 20
    validator = LiveValidations::Adapters::JqueryValidations.new(Post.new)
    
    expected_json = {"post[title]" => {"minlength" => 20}}
    assert_equal expected_json, validator.json_data
  end
end