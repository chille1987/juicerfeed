require "test_helper"

class PostsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @source = sources(:one)
  end

  test "should get index" do
    get posts_path
    assert_response :success
  end

  test "does not render active filters when no filters are applied" do
    get posts_path
    assert_response :success
    assert_select ".filter-bar__active", count: 0
  end

  test "renders active filters when platform filter is applied" do
    get posts_path, params: { post: { platform: "facebook" } }
    assert_response :success
    assert_select ".filter-bar__active", count: 1
    assert_select ".filter-tag__label", text: "Platform:"
    assert_select ".filter-tag__value", text: "Facebook"
  end

  test "renders active filters when media_type filter is applied" do
    get posts_path, params: { post: { media_type: "Image" } }
    assert_response :success
    assert_select ".filter-bar__active", count: 1
    assert_select ".filter-tag__label", text: "Media type:"
    assert_select ".filter-tag__value", text: "Image"
  end

  test "renders source filter tag when source_id is applied" do
    get posts_path, params: { post: { source_id: @source.id } }
    assert_response :success

    assert_select ".filter-bar__active", count: 1
    assert_select ".filter-tag__label", text: "Source:"
    assert_select ".filter-tag__value", text: "#{@source.platform} – #{@source.username}"
  end
end
