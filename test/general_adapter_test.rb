require File.join(File.dirname(__FILE__), "test_helper")

class GeneralAdapterTest < ActiveSupport::TestCase
  def setup
    reset_callbacks Post
    @post = Post.new
    @hook = LiveValidations::Adapter::ValidationHook.new
  end
  
  def teardown
    restore_callbacks Post
  end
  
  def test_message_for_with_custom_message
    @hook.expects(:callback).returns(OpenStruct.new(:options => {:message => "Yep!"}))
    assert_equal "Yep!", @hook.message_for(:blank)
  end
  
  def test_message_for_without_custom_message
    @hook.expects(:callback).returns(OpenStruct.new(:options => {}))
    assert_equal I18n.translate('activerecord.errors.messages')[:blank], @hook.message_for(:blank)
  end
  
  def test_utilizes_inline_javascript_with_data_and_proc
    LiveValidations::Adapter.expects(:setup_proc).returns(Proc.new {})
    LiveValidations::Adapter.expects(:inline_javascript_proc).returns(Proc.new {})
    
    adapter = LiveValidations::Adapter.new(@post)
    adapter.expects(:data).returns({:not => "blank"})
    assert adapter.utilizes_inline_javascript?
  end
  
  def test_utilizes_inline_javascript_with_blank_data_and_proc
    LiveValidations::Adapter.expects(:setup_proc).returns(Proc.new {})
    LiveValidations::Adapter.expects(:inline_javascript_proc).returns(Proc.new {})
    
    adapter = LiveValidations::Adapter.new(@post)
    adapter.expects(:data).returns({})
    assert !adapter.utilizes_inline_javascript?
  end
  
  def test_utilizes_inline_javascript_without_json_proc
    LiveValidations::Adapter.expects(:setup_proc).returns(Proc.new {})
    LiveValidations::Adapter.expects(:inline_javascript_proc).returns(nil)
    # No point in mocking .json or .data, because it'll never get called anyway.
    
    adapter = LiveValidations::Adapter.new(@post)
    assert !adapter.utilizes_inline_javascript?
  end
  
  def test_format_regex_whith_custom_js_regex
    Post.validates_format_of :title, :with => /foo/, :live_validator => /bar/
    @hook.expects(:callback).returns(@post.validation_callbacks.first)
    assert_equal /bar/, @hook.format_regex
  end
  
  def test_format_regex_using_ruby_regex
    Post.validates_format_of :title, :with => /foo/
    @hook.expects(:callback).times(2).returns(@post.validation_callbacks.first)
    assert_equal /foo/, @hook.format_regex
  end
  
  def test_not_specifying_an_adapter
    LiveValidations.current_adapter = nil
    assert_raises(LiveValidations::AdapterNotSpecified) { LiveValidations.current_adapter }
  end
  
  def test_specifying_adapter_as_class
    LiveValidations.use(LiveValidations::Adapters::JqueryValidations)
    assert_equal LiveValidations::Adapters::JqueryValidations, LiveValidations.current_adapter
  end
  
  def test_specifying_adapter_as_string
    LiveValidations.use("jquery_validations")
    assert_equal LiveValidations::Adapters::JqueryValidations, LiveValidations.current_adapter
  end
  
  def test_specifying_adapter_as_symbol
    LiveValidations.use(:jquery_validations)
    assert_equal LiveValidations::Adapters::JqueryValidations, LiveValidations.current_adapter
  end
  
  def test_specifying_invalid_adapter_as_symbol
    assert_raises(LiveValidations::AdapterNotFound) { LiveValidations.use(:meh) }
  end
end