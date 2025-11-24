require "test_helper"

class FeedSyncsControllerTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  test "POST /feed_sync enqueues FetchPostsJob and redirects to posts index" do
    clear_enqueued_jobs

    assert_enqueued_with(job: FetchPostsJob) do
      post feed_sync_path
    end

    assert_redirected_to posts_path
    assert_equal "Fetching posts started… Please reload the page to see the latest posts.", flash[:notice]
  end
end
