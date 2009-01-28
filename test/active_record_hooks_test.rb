require File.join(File.dirname(__FILE__), "test_helper")

class ActiveRecordHooksTest < Test::Unit::TestCase
  def setup
    reset_callbacks Post
  end
  
  def test_validation_callbacks_for_on_new_record
    post = new_post
    Post.validates_presence_of :title
    Post.validates_length_of :title, :maximum => 50
    # This one is ignored, as it's on update, and the post is a new record.
    Post.validates_format_of :body, :with => /silly/, :on => :update

    validators = post.validation_callback_for(:title)
    assert_equal 2, validators.size
    
    assert validators.detect {|v| v.options[:validation_method] == :length }
    assert validators.detect {|v| v.options[:validation_method] == :presence }
    
    assert !post.validation_callback_for(:body).detect {|v| v.options[:validation_method] == :format}
  end
  
  def test_validation_callbacks_for_on_existing_record
    post = create_post
    Post.validates_presence_of :title
    Post.validates_length_of :title, :maximum => 50
    # This one is ignored, as it's on update, and the post is a new record.
    Post.validates_format_of :body, :with => /silly/, :on => :create
    
    validators = post.validation_callback_for(:title)
    assert_equal 2, validators.size
    
    assert validators.detect {|v| v.options[:validation_method] == :length }
    assert validators.detect {|v| v.options[:validation_method] == :presence }
    
    assert !post.validation_callback_for(:body).detect {|v| v.options[:validation_method] == :format}
  end
  
  def teardown
    restore_callbacks Post
  end
  
  private
  
  def new_post
    Post.new(:title => "Yarr", :excerpt => "Yep", :body => "Yap")
  end
  
  def create_post
    p = new_post
    p.save
    p
  end
end