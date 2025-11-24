class FeedSyncsController < ApplicationController
  def create
    FetchPostsJob.perform_later

    redirect_to posts_path, notice: "Fetching posts started… Please reload the page to see the latest posts."
  end
end
