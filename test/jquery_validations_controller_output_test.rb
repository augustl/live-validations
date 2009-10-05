require File.join(File.dirname(__FILE__), "test_helper")

class JqueryValidationsControllerOutputTest < Test::Unit::TestCase
  def setup
    reset_database
    reset_callbacks Post
    LiveValidations.use(LiveValidations::Adapters::JqueryValidations)
  end
  
  def teardown
    restore_callbacks Post
  end
  
  def test_without_live_validations
    render <<-eof
    <% form_for(Post.new) do |f| %>
      <%= f.text_field :title %>
    <% end %>
    eof
    
    assert_html 'form#new_post'
    assert_no_html "script[type=text/javascript]"
  end
  
  def test_json_output
    Post.validates_presence_of :title
    
    render
    
    assert_html "script[type=text/javascript]"
    assert rendered_view.include?("$('#new_post').validate")
    
    expected_json = {
      "rules" => {
        "post[title]" => {"required" => true}
      },
      "messages" => {
        "post[title]" => {"required" => "can't be blank"}
      }
    }
    
    assert rendered_view.include?(expected_json.to_json)
  end
  
  def test_validator_options_with_function
    Post.validates_presence_of :title
    LiveValidations.use LiveValidations::Adapters::JqueryValidations, :validator_settings => {"errorPlacement" => "function(error, element) { error.appendTo(element.prev('label')); }"}

    render

    assert rendered_view.include?(%["errorPlacement":function(error, element) { error.appendTo(element.prev('label')); }])
  end
 
  def test_validator_options
    Post.validates_presence_of :title
    LiveValidations.use LiveValidations::Adapters::JqueryValidations, :validator_settings => {"errorElement" => "span"}
    
    render
    
    assert rendered_view.include?(%{"errorElement":"span"})
  end
  
  def test_validation_on_attributes_without_form_field
    Post.validates_presence_of :title
    
    render <<-eof
    <% form_for(Post.new, :live_validations => true) do |f| %>
      <%= f.text_field :excerpt %>
    <% end %>
    eof
    
    assert rendered_view.include?(%{"messages":{}})
    assert rendered_view.include?(%{"rules":{}})
    assert !rendered_view.include?("post[title]")
  end
  
  def test_silly_form_for_input
    assert_raises(LiveValidations::InvalidFormBuilderObject) {
      render <<-eof
      <% form_for(Object.new, :live_validations => true) do |f| %>
      <% end %>
      eof
    }
  end
  
  def test_symbol_as_form_for_input_with_ivar
    render <<-eof
    <% @post = Post.new %>
    <% form_for :post, :live_validations => true do |f| %>
    <% end %>
    eof
    
    assert_html "script[type=text/javascript]"
  end
  
  def test_symbol_as_form_for_input_with_silly_ivar
    assert_raises(LiveValidations::InvalidFormBuilderObject) {
      render <<-eof
      <% @post = Object.new %>
      <% form_for :post, :live_validations => true do |f| %>
      <% end %>
      eof
    }
  end
  
  def test_symbol_as_form_for_input_with_no_ivar
    assert_raises(LiveValidations::InvalidFormBuilderObject) {
      render <<-eof
      <% form_for :does_not_exist, :live_validations => true do |f| %>
      <% end %>
      eof
    }
  end
end