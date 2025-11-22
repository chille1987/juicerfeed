class PostsController < ApplicationController
  def index
    @filter = filter_params

    scope = Post
              .feed_order
              .includes(:source)
              .by_platform(@filter[:platform])
              .by_media_type(@filter[:media_type])
              .by_source_id(@filter[:source_id])

    @pagy, @posts = pagy(:offset, scope)

    @platforms = Source.distinct.order(:platform).pluck(:platform)
    @media_types = Post.distinct.order(:media_type).pluck(:media_type).compact
    @sources = Source.order(:username)
  end

  private

  def filter_params
    params.fetch(:post, {}).permit(:platform, :media_type, :source_id)
  end
end
