class PostsController < ApplicationController
  def index
    @pagy, @posts = pagy(:offset, Post.feed_order.includes(:source))
  end
end
