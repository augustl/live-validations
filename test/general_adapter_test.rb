require File.join(File.dirname(__FILE__), "test_helper")

class GeneralAdapterTest < ActiveSupport::TestCase
  def setup
    reset_callbacks Post
    @post = Post.new
    @hook = LiveValidations::Adapter::ValidationHook.new
    @adapter = LiveValidations::Adapter.new(@post)
  end
  
  def teardown
    restore_callbacks Post
  end
  
  def test_utilizes_json_with_data_and_proc
    LiveValidations::Adapter.expects(:json_proc).returns(Proc.new {})
    @adapter.expects(:json).returns({:not => "blank"})
    assert @adapter.utilizes_json?
  end
  
  def test_utilizes_json_with_json_and_proc
    LiveValidations::Adapter.expects(:json_proc).returns(Proc.new {})
    @adapter.expects(:data).returns(:not => ["blank"])
    assert @adapter.utilizes_json?
  end
  
  def test_utilizes_json_with_blank_json_or_data_for_that_matter
    LiveValidations::Adapter.expects(:json_proc).returns(Proc.new {})
    @adapter.expects(:json).returns({})
    assert !@adapter.utilizes_json?
  end
  
  def test_utilizes_json_without_json_proc
    LiveValidations::Adapter.expects(:json_proc).returns(nil)
    # No point in mocking .json or .data, because it'll never get called anyway.
    assert !@adapter.utilizes_json?
  end
end