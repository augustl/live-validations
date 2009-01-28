class PostsController < ApplicationController
  def index
    @posts = Post.find(:all)
  end

  def new
    @post = Post.new
  end
end
