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

    @active_filters = get_active_filters(@filter, @sources)
  end

  private

  def filter_params
    params.fetch(:post, {}).permit(:platform, :media_type, :source_id)
  end

  def get_active_filters(filter, sources)
    filters = []

    if filter[:platform].present?
      filters << { key: :platform, label: "Platform", value: filter[:platform].to_s.titleize }
    end

    if filter[:media_type].present?
      filters << { key: :media_type, label: "Media type", value: filter[:media_type].to_s.titleize }
    end

    if filter[:source_id].present?
      source = sources.find { |s| s.id.to_s == filter[:source_id].to_s }
      if source
        filters << { key: :source_id, label: "Source", value: "#{source.platform} – #{source.username}" }
      end
    end

    filters
  end
end
