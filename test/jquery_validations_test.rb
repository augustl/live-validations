require File.join(File.dirname(__FILE__), "test_helper")

LiveValidations.use(LiveValidations::Adapters::JqueryValidations)

class JqueryValidationsTest < ActiveSupport::TestCase
  def setup
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
  
  def test_confirmation
    Post.validates_confirmation_of :password
    assert_expected_json "post[password_confirmation]" => {"equalTo" => "#post_password"}
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
    
    assert_custom_validator('title')
  end

  def test_validates_acceptance_of
    Post.validates_acceptance_of :check_me
    assert_expected_json "post[check_me]" => {"required" => true}
  end
  
  def test_validates_length_of_within
    Post.validates_length_of :title, :within => 4..40
    assert_expected_json "post[title]" => {"rangelength" => [4, 40]}
  end
  
  def test_validates_length_of_maximum
    Post.validates_length_of :title, :maximum => 20
    assert_expected_json "post[title]" => {"maxlength" => 20}
  end
  
  def test_validates_length_of_minimum
    Post.validates_length_of :title, :minimum => 20
    assert_expected_json "post[title]" => {"minlength" => 20}
  end
  
  def test_inclusion_as_array
    Post.validates_inclusion_of :title, :in => %w(foo bar)
    assert_custom_validator 'title'
  end
  
  def test_inclusion_as_range
    Post.validates_inclusion_of :title, :in => 5..10
    assert_expected_json "post[title]" => {"range" => [5, 10]}
  end
  
  def test_uniqueness
    Post.validates_uniqueness_of :title
    assert_expected_json "post[title]" => {"remote" => "/live_validations/uniqueness?model_class=Post"}
  end
  
  def assert_expected_json(expected_json)
    validator = LiveValidations::Adapters::JqueryValidations.new(Post.new)
    assert_equal expected_json, validator.json_data
  end
  
  def assert_custom_validator(attribute)
    validator = LiveValidations::Adapters::JqueryValidations.new(Post.new)
    custom_validator_key = validator.render_json[/jQuery\.validator\.addMethod\('([a-f0-9]+)/, 1]
    expected_json = {"post[#{attribute}]" => {custom_validator_key => true}}
    assert_equal expected_json, validator.json_data
    
  end
end