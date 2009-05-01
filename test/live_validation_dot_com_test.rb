require File.join(File.dirname(__FILE__), "test_helper")

class LiveValidationsDotComTest < ActiveSupport::TestCase
  def setup
    reset_database
    reset_callbacks Post
    LiveValidations.use(LiveValidations::Adapters::LivevalidationDotCom)
  end
  
  def teardown
    restore_callbacks Post
  end
  
  def test_presence
    Post.validates_presence_of :title
    assert_validators :title, "Presence"
  end
  
  def test_format
    Post.validates_format_of :title, :with => /ohai/
    assert_validators :title, "Format", :pattern => /ohai/
  end
  
  def test_numericality
    Post.validates_numericality_of :age
    assert_validators :age, "Numericality"
  end
  
  def test_length_with_minimum
    Post.validates_length_of :title, :minimum => 10
    assert_validators :title, "Length", :minimum => 10
  end
  
  def test_length_with_maximum
    Post.validates_length_of :title, :maximum => 10
    assert_validators :title, "Length", :maximum => 10
  end
  
  def test_length_with_range
    Post.validates_length_of :title, :within => 10..20
    assert_validators :title, "Length", :minimum => 10, :maximum => 20
  end
  
  def test_length_with_is
    Post.validates_length_of :title, :is => 20
    assert_validators :title, "Length", :is => 20
  end
  
  def test_inclusion_with_numeric_range
    Post.validates_inclusion_of :age, :in => 10..20
    assert_validators :age, "Numericality", :minimum => 10, :maximum => 20
  end
  
  def test_inclusion_with_string_range
    Post.validates_inclusion_of :title, :in => "a".."f"
    assert_validators :title, "Inclusion", :within => %w(a b c d e f)
  end
  
  def test_inclusion_with_array
    Post.validates_inclusion_of :title, :in => ["Darn", "that", "cencorship"]
    assert_validators :title, "Inclusion", :within => ["Darn", "that", "cencorship"]
  end
  
  def test_exclusion_of_with_range
    Post.validates_exclusion_of :age, :in => 0..4
    assert_validators :age, "Exclusion", :within => [0, 1, 2, 3, 4]
  end
  
  def test_exclusion_of_with_array
    Post.validates_exclusion_of :title, :in => ["Admin", "Only"]
    assert_validators :title, "Exclusion", :within => ["Admin", "Only"]
  end
  
  def test_acceptance
    Post.validates_acceptance_of :check_me
    assert_validators :check_me, "Acceptance"
  end
  
  def test_confirmation
    Post.validates_confirmation_of :password
    assert_validators :password_confirmation, "Confirmation", :match => "post_password"
  end
  
  def assert_validators(attribute, expected_validator, json = {})
    validator = LiveValidations.current_adapter.new(Post.new)
    validator.expects(:callback_has_visible_attributes?).returns(true)
    validator.run_validations
    
    assert validator[:validators][attribute].has_key?(expected_validator), "The validator did not include `#{expected_validator}'."

    json.each do |key, value|
      assert_equal value, validator[:validators][attribute][expected_validator][key]
    end
  end
end