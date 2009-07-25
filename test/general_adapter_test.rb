require File.join(File.dirname(__FILE__), "test_helper")

class GeneralAdapterTest < Test::Unit::TestCase
  def setup
    reset_database
    reset_callbacks Post
    @post = Post.new
    @hook = LiveValidations::AdapterBase::ValidationHook.new
  end
  
  def teardown
    restore_callbacks Post
  end
  
  def test_message_for_with_custom_message
    @hook.expects(:callback).at_least_once.returns(OpenStruct.new(:options => {:message => "Yep!"}))
    @hook.expects(:adapter_instance).returns(OpenStruct.new(:active_record_instance => @post))
    
    assert_equal "Yep!", @hook.message_for(:title, :blank)
  end
  
  def test_message_for_with_l18n_fancy_message
    @hook.expects(:callback).at_least_once.returns(OpenStruct.new(:options => {:message => "The {{model}} {{attribute}}"}))
    @hook.expects(:adapter_instance).returns(OpenStruct.new(:active_record_instance => @post))
    
    assert_equal "The Post title", @hook.message_for(:title, :blank)
  end
  
  def test_message_for_without_custom_message
    @hook.expects(:callback).returns(OpenStruct.new(:options => {}))
    assert_equal I18n.translate('activerecord.errors.messages')[:blank], @hook.message_for(:title, :blank)
  end
  
  def test_utilizes_inline_javascript_with_data_and_proc
    LiveValidations::AdapterBase.expects(:setup_proc).returns(Proc.new {})
    LiveValidations::AdapterBase.expects(:inline_javascript_proc).returns(Proc.new {})
    
    adapter = LiveValidations::AdapterBase.new(@post)
    adapter.expects(:data).returns({:not => "blank"})
    assert adapter.utilizes_inline_javascript?
  end
  
  def test_utilizes_inline_javascript_with_blank_data_and_proc
    LiveValidations::AdapterBase.expects(:setup_proc).returns(Proc.new {})
    LiveValidations::AdapterBase.expects(:inline_javascript_proc).returns(Proc.new {})
    
    adapter = LiveValidations::AdapterBase.new(@post)
    adapter.expects(:data).returns({})
    assert !adapter.utilizes_inline_javascript?
  end
  
  def test_utilizes_inline_javascript_without_json_proc
    LiveValidations::AdapterBase.expects(:setup_proc).returns(Proc.new {})
    LiveValidations::AdapterBase.expects(:inline_javascript_proc).returns(nil)
    # No point in mocking .json or .data, because it'll never get called anyway.
    
    adapter = LiveValidations::AdapterBase.new(@post)
    assert !adapter.utilizes_inline_javascript?
  end
  
  def test_regex_whith_custom_js_regex
    Post.validates_format_of :title, :with => /foo/, :live_validator => /bar/
    @hook.expects(:callback).returns(@post.validation_callbacks.first)
    assert_equal /bar/, @hook.regex
  end
  
  def test_regex_using_ruby_regex
    Post.validates_format_of :title, :with => /foo/
    @hook.expects(:callback).times(2).returns(@post.validation_callbacks.first)
    assert_equal /foo/, @hook.regex
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
  
  def test_with_validation_that_has_no_attribute
    Post.validate {|r| }
    
    LiveValidations::AdapterBase.expects(:setup_proc).returns(Proc.new {})
    adapter = LiveValidations::AdapterBase.new(@post)
    
    # This test should probably be improved. The plugin used to raise an error when
    # the model had attribute-less validations, which is what this tests tries to
    # prove.
    assert_nothing_raised { adapter.run_validations }
  end
  
  def test_various_types_of_form_helpers
    render <<-eof
    <% @post = Post.new %>
    <% form_for :post, :live_validations => true do |f| %>
        <%= f.text_field :title %>
        <%= f.select :title, ["foo", "bar", "baz"] %>
    <% end %>
    eof
    
    assert_html "script[type=text/javascript]"
  end
  
  def test_model_with_multiple_words
    LiveValidations.use :jquery_validations
    UserSession.validates_presence_of :login
    
    render <<-eof
    <% form_for UserSession.new, :live_validations => true do |f| %>
      <%= f.text_field :login %>
    <% end %>
    eof
    
    assert_html "input#user_session_login"
    assert @rendered_view.include?(%{"user_session[login]":})
  end
end