class AnalyticsController < ApplicationController
  def index
    @top_posts_by_views = Post.includes(:source).top_by_views(5)
    @top_posts_by_likes = Post.includes(:source).top_by_likes(5)
    @top_posts_by_comments = Post.includes(:source).top_by_comments(5)
    @top_posts_by_shares = Post.includes(:source).top_by_shares(5)
  end
end
