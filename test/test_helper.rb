require 'test/unit'
require 'ostruct'

require 'rubygems'
require 'active_support'
require 'action_controller'
require 'action_controller/test_case'
require 'action_view'
require 'active_record'
require 'mocha'

$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
require File.join(File.dirname(__FILE__), '..', 'init')

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :dbfile => ":memory:")

class Post < ActiveRecord::Base
  has_many :comments, :order => "position"
end

class UserSession < ActiveRecord::Base
end

ActiveSupport::Deprecation.silenced = true
ActiveRecord::Migration.verbose = false

ActionController::Routing::Routes.draw do |map|
  map.resources :posts, :user_sessions
  map.connect ":controller/:action/:id"
end

class ApplicationController < ActionController::Base
end

class PostsController < ApplicationController
end


class Test::Unit::TestCase
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
    return if @original_callbacks.blank?
    
    @_original_callbacks.each do |name, callback|
      model.instance_variable_set("@#{name}", callback)
    end
  end
  
  def reset_database
    silence_stream(STDOUT) do
      ActiveRecord::Schema.define(:version => 1) do
        create_table :posts, :force => true do |t|
          t.string :title
          t.text :excerpt, :body
        end
        
        create_table :user_sessions, :force => true do |t|
          t.string :login
        end
      end
    end
  end
  
  def view
    @view ||= begin
      view_instance = ActionView::Base.new
      view_instance.instance_eval {
        @request = ActionController::TestRequest.new
        @response = ActionController::TestResponse.new
        
        action = "index"
        params = {:controller => "posts", :action => action}
        
        @controller = PostsController.new
        @controller.request = @request
        @controller.params = params
        @controller.send(:initialize_current_url)
        
        @request.action = "index"
        @request.assign_parameters(@controller.class.controller_path, "index", params)
      }
      
      class << view_instance
        def protect_against_forgery?
          false
        end
      end
      
      view_instance
    end
  end
  
  def render(template = nil)
    template ||= <<-eof
    <% form_for(Post.new, :live_validations => true) do |f| %>
      <%= f.text_field :title %>
    <% end %>
    eof
    
    @rendered_view = view.render(:inline => template)
  end
  
  def rendered_view
    @rendered_view || raise("You have to call `render' before calling `rendered_view'.")
  end
  
  def assert_html(selector)
    assert count_nodes(@rendered_view, selector) > 0
  end
  
  def assert_no_html(selector)
    assert count_nodes(@rendered_view, selector) == 0
  end
  
  def count_nodes(html, selector)
    HTML::Selector.new(selector).select(HTML::Document.new(html).root).size
  end
end

class ActionView::InlineTemplate
  def relative_path
    ""
  end
end