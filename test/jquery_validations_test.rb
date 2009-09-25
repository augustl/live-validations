require File.join(File.dirname(__FILE__), "test_helper")

class JqueryValidationsTest < ActiveSupport::TestCase
  def setup
    reset_database
    reset_callbacks Post
    LiveValidations.use(LiveValidations::Adapters::JqueryValidations)
  end
  
  def teardown
    restore_callbacks Post
  end
  
  def test_presence
    Post.validates_presence_of :title
    assert_expected_json :title => {"required" => true}
  end
  
  def test_confirmation
    Post.validates_confirmation_of :password
    assert_expected_json :password_confirmation => {"equalTo" => "#post_password", "required" => true}
  end
  
  def test_validates_format_of_without_custom_javascript_format
    Post.validates_format_of :title, :with => /^[a-z0-9]+$/
    validator = LiveValidations::Adapters::JqueryValidations.new(Post.new)
    validator.expects(:callback_has_visible_attributes?).returns(true)
    validator.run_validations
    
    custom_validator_key = validator.render_inline_javascript[/jQuery\.validator\.addMethod\('([a-f0-9]+)/, 1]
    expected_json = {:title => {custom_validator_key => true}}
    assert_equal expected_json, validator[:validators]
  end
  
  def test_validates_format_of_with_custom_javascript_format
    Post.validates_format_of :title, :with => /^some odd ruby specific thing$/, :live_validator => '[a-z0-9]'
    validator = LiveValidations::Adapters::JqueryValidations.new(Post.new)
    validator.expects(:callback_has_visible_attributes?).returns(true)
    validator.run_validations
    
    assert validator.render_inline_javascript.include?("[a-z0-9]")
    assert !validator.render_inline_javascript.include?('some odd ruby specific thing')
    
    assert_custom_validator(:title)
  end
  
  def test_validates_acceptance_of
    Post.validates_acceptance_of :check_me
    assert_expected_json :check_me => {"required" => true}
  end
  
  def test_validates_length_of_within
    Post.validates_length_of :title, :within => 4..40
    assert_expected_json :title => {"rangelength" => [4, 40]}
  end
  
  def test_validates_length_of_maximum
    Post.validates_length_of :title, :maximum => 20
    assert_expected_json :title => {"maxlength" => 20}
  end
  
  def test_validates_length_of_minimum
    Post.validates_length_of :title, :minimum => 20
    assert_expected_json :title => {"minlength" => 20}
  end
  
  def test_validates_length_of_is
    Post.validates_length_of :title, :is => 20
    assert_expected_json :title => {"lengthIs20" => true}
  end
  
  def test_inclusion_as_array
    Post.validates_inclusion_of :title, :in => %w(foo bar)
    assert_custom_validator :title
  end
  
  def test_inclusion_as_range
    Post.validates_inclusion_of :title, :in => 5..10
    assert_expected_json :title => {"range" => [5, 10]}
  end
  
  def test_uniqueness
    Post.validates_uniqueness_of :title
    assert_expected_json :title => {"remote" => "/live_validations/uniqueness?model_class=Post"}
  end
  
  def assert_expected_json(expected_json)
    validator = LiveValidations::Adapters::JqueryValidations.new(Post.new)
    validator.expects(:callback_has_visible_attributes?).returns(true)
    validator.run_validations
    
    assert_equal expected_json, validator[:validators]
  end
  
  def assert_custom_validator(attribute)
    validator = LiveValidations::Adapters::JqueryValidations.new(Post.new)
    validator.expects(:callback_has_visible_attributes?).returns(true)
    validator.run_validations
    
    custom_validator_key = validator.render_inline_javascript[/jQuery\.validator\.addMethod\('([a-f0-9]+)/, 1]
    assert custom_validator_key, "The custom validator key was not found."
    
    expected_json = {attribute => {custom_validator_key => true}}
    assert_equal expected_json, validator[:validators]
  end
end