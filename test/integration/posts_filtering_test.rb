require "test_helper"

class PostsFilteringTest < ActionDispatch::IntegrationTest
  def setup
    @post1 = posts(:one)
    @post2 = posts(:two)
  end

  test "index filters by platform" do
    get posts_path, params: { post: { platform: "instagram" } }
    assert_response :success
    assert_includes response.body, @post1.content
    refute_includes response.body, @post2.content
  end

  test "index filters by media type" do
    get posts_path, params: { post: { media_type: "video" } }
    assert_response :success
    assert_includes response.body, @post2.content
    refute_includes response.body, @post1.content
  end

  test "index filters by source" do
    get posts_path, params: { post: { source_id: @post1.id } }
    assert_response :success
    assert_includes response.body, @post1.content
    refute_includes response.body, @post2.content
  end
end
