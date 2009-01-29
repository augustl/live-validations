# Rip-off from the Shoulda test suite. Thanks, Shoulda!

ENV['RAILS_ENV'] = 'sqlite3'
rails_root = File.join(File.dirname(__FILE__), 'rails_root')

# Load the rails environment
require File.join(rails_root, 'config', 'environment.rb')

# Load the testing framework
require 'test_help'
silence_warnings { RAILS_ENV = ENV['RAILS_ENV'] }

# Run the migrations
ActiveRecord::Migration.verbose = false
ActiveRecord::Migrator.migrate File.join(rails_root, 'db', 'migrate')

Test::Unit::TestCase.fixture_path = File.join(File.dirname(__FILE__), 'fixtures')

class Test::Unit::TestCase #:nodoc:
  def create_fixtures(*table_names)
    if block_given?
      Fixtures.create_fixtures(Test::Unit::TestCase.fixture_path, table_names) { yield }
    else
      Fixtures.create_fixtures(Test::Unit::TestCase.fixture_path, table_names)
    end
  end
 
  self.use_transactional_fixtures = false
  self.use_instantiated_fixtures  = false
  
  def reset_callbacks(model)
    @_original_callbacks = {}
    
    [:validate_callbacks, :validate_on_create_callbacks, :validate_on_update_callbacks].each do |callback|
      # Store it for restore later on
      @_original_callbacks[callback] = model.instance_variable_get("@#{callback}")
      # Remove it
      model.instance_variable_set("@#{callback}", ActiveSupport::Callbacks::CallbackChain.new)
    end
  end
  
  # Be nice to other test files and run this in teardown.
  def restore_callbacks(model)
    @_original_callbacks.each do |name, callback|
      model.instance_variable_set("@#{name}", callback)
    end
  end
  
  #def render(template)
  #  @output = @view.render_template(ActionView::InlineTemplate.new(@view, template))
  #end
end