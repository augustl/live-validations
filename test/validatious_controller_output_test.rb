require File.join(File.dirname(__FILE__), "test_helper")

class ValidatiousControllerOutputTest < ActionController::TestCase
  def setup
    reset_database
    reset_callbacks Post
    LiveValidations.use(LiveValidations::Adapters::Validatious)
  end
  
  def teardown
    restore_callbacks Post
  end
  
  def test_one_option_hash_helpers
    Post.validates_presence_of :title
    
    render %{
      <% form_for(Post.new, :live_validations => true) do |f| %>
          <%= f.text_field :title %>
      <% end %>
    }
    
    assert_html 'input[type=text]#post_title.required'
  end
  
  def test_one_option_hash_helper_with_options
    Post.validates_presence_of :title
    
    render %{
      <% form_for(Post.new, :live_validations => true) do |f| %>
          <%= f.text_field :title, :id => "a_custom_id" %>
      <% end %>
    }
    
    assert_html 'input[type=text]#a_custom_id.required'
  end
  
  def test_confirmation
    Post.validates_confirmation_of :password
    Post.send(:attr_accessor, :password)
    
    render %{
      <% form_for(Post.new, :live_validations => true) do |f| %>
          <%= f.password_field :password %>
          <%= f.password_field :password_confirmation %>
      <% end %>
    }
    
    assert_html 'input[type=password]#post_password_confirmation.confirmation-of_post_password'
  end
  
  def test_select_tag_with_one_option_hash
    Post.validates_presence_of :title
    
    render %{
      <% form_for(Post.new, :live_validations => true) do |f| %>
        <%= f.select :title, ["foo", "bar"], :include_blank => true %>
      <% end %>
    }
    
    assert_html 'select#post_title'
    assert_html 'select option[value=""]'
    assert_html 'select.required'
  end
  
  def test_select_tag_with_two_option_hashes
    Post.validates_presence_of :title
    
    render %{
      <% form_for(Post.new, :live_validations => true) do |f| %>
        <%= f.select :title, ["foo", "bar"], {:include_blank => true}, :id => "a_custom_id" %>
      <% end %>
    }
    
    assert_html 'select#a_custom_id'
    assert_html 'select option[value=""]'
    assert_html 'select.required'
  end
end