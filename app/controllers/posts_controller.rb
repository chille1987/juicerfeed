class PostsController < ApplicationController
  def index
    @pagy, @posts = pagy(:offset, Post.recent.includes(:source))
  end
end
