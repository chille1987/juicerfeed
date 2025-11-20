class PostsController < ApplicationController
  def index
    @posts = Post.recent.includes(:source)
  end
end
