class CreatePosts < ActiveRecord::Migration
  def self.up
    create_table :posts do |t|
      t.string :title, :category
      t.text :excerpt, :body
      # A bit silly for a post, but who cares.
      t.string :password, :password_confirmation
      t.boolean :check_me
      t.timestamps
    end
  end

  def self.down
    drop_table :posts
  end
end
