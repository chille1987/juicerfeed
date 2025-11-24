require "test_helper"

class PostTest < ActiveSupport::TestCase
  def setup
    @source = sources(:one)
    @post = posts(:one)
  end

  def build_post(attrs = {})
    Post.new({ source: @source, profile_image: "https://example.com/p.png", content: "hello", media_type: "text", media_url: nil, hashtags: "#hi", mentions: "@you", likes: 1, comments: 0, shares: 0, views: 10, is_promoted: false, location: "Barcelona" }.merge(attrs))
  end

  test "Baseline is valid" do
    assert @post.valid?
  end

  test "Post without source is not valid" do
    post = build_post(source: nil)
    assert_not post.valid?
    assert_includes post.errors[:source], "must exist"
  end

  test "Post without correct media_type is not valid" do
    post = build_post(media_type: "juicer")
    assert_not post.valid?
    assert_includes post.errors[:media_type], "is not included in the list"
  end

  test "Recent posts orders by created_at descending" do
    older = build_post(created_at: 2.days.ago)
    older.save!
    newer = build_post(created_at: 1.day.ago)
    newer.save!
    ids = Post.recent.pluck(:id)
    assert ids.index(newer.id) < ids.index(older.id)
  end

  test "media_type normalization works" do
    post1 = build_post(media_type: "ImAge")
    post1.validate
    assert_equal "image", post1.media_type

    post2 = build_post(media_type: nil)
    post2.validate
    assert_equal "text", post2.media_type
  end

  test "media_url must be http or https" do
    post = build_post(media_url: "javascript:alert(1)")

    assert_not post.valid?
    assert_includes post.errors[:media_url], "must be a valid http(s) URL"
  end

  test "top_by_views returns posts ordered by views desc and limited" do
    Post.delete_all

    post1 = Post.create!(source: @source, media_type: "text", views: 10, likes: 0, comments: 0, shares: 0)
    post2 = Post.create!(source: @source, media_type: "text", views: 50, likes: 0, comments: 0, shares: 0)
    post3 = Post.create!(source: @source, media_type: "text", views: 30, likes: 0, comments: 0, shares: 0)

    result = Post.top_by_views(2)

    assert_equal [ post2, post3 ], result
  end

  test "top_by_likes returns posts ordered by likes desc and limited" do
    Post.delete_all

    post1 = Post.create!(source: @source, media_type: "text", views: 10, likes: 13, comments: 0, shares: 0)
    post2 = Post.create!(source: @source, media_type: "text", views: 50, likes: 23, comments: 0, shares: 0)
    post3 = Post.create!(source: @source, media_type: "text", views: 30, likes: 33, comments: 0, shares: 0)

    result = Post.top_by_likes(2)

    assert_equal [ post3, post2 ], result
  end

  test "top_by_comments returns posts ordered by comments desc and limited" do
    Post.delete_all

    post1 = Post.create!(source: @source, media_type: "text", views: 10, likes: 13, comments: 10, shares: 0)
    post2 = Post.create!(source: @source, media_type: "text", views: 50, likes: 23, comments: 5, shares: 0)
    post3 = Post.create!(source: @source, media_type: "text", views: 30, likes: 33, comments: 8, shares: 0)

    result = Post.top_by_comments(2)

    assert_equal [ post1, post3 ], result
  end

  test "top_by_shares returns posts ordered by shares desc and limited" do
    Post.delete_all

    post1 = Post.create!(source: @source, media_type: "text", views: 10, likes: 13, comments: 10, shares: 2)
    post2 = Post.create!(source: @source, media_type: "text", views: 50, likes: 23, comments: 5, shares: 0)
    post3 = Post.create!(source: @source, media_type: "text", views: 30, likes: 33, comments: 8, shares: 4)

    result = Post.top_by_shares(2)

    assert_equal [ post3, post1 ], result
  end
end
