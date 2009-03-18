require File.join(File.dirname(__FILE__), "test_helper")

class ActiveRecordHooksTest < ActiveSupport::TestCase
  def setup
    reset_database
    reset_callbacks Post
  end
  
  def teardown
    restore_callbacks Post
  end
  
  def test_validation_callbacks_for_on_new_record
    assert_callback_hooks(new_post)
  end
  
  def test_validation_callbacks_for_on_existing_record
    assert_callback_hooks(create_post)
  end
    
  private
  
  def assert_callback_hooks(post)
    Post.validates_presence_of :title
    Post.validates_length_of :title, :maximum => 50
    
    validators = post.validation_callback_for(:title)
    assert_equal 2, validators.size
    
    assert validators.detect {|v| v.options[:validation_method] == :length }
    assert validators.detect {|v| v.options[:validation_method] == :presence }
    
    Post.validates_format_of :body, :with => /silly/, :on => (post.new_record? ? :update : :create)
    assert !post.validation_callback_for(:body).detect {|v| v.options[:validation_method] == :format}
    
    Post.validates_format_of :body, :with => /silly/, :on => (post.new_record? ? :create : :update)
    assert post.validation_callback_for(:body).detect {|v| v.options[:validation_method] == :format}
  end
  
  def new_post
    Post.new(:title => "Yarr", :excerpt => "Yep", :body => "Yap")
  end
  
  def create_post
    p = new_post
    p.save
    p
  end
end