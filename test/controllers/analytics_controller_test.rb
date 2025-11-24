require "test_helper"

class AnalyticsControllerTest < ActionDispatch::IntegrationTest
  test "Should get index route" do
    get analytics_path
    assert_response :success
  end

  test "index renders analytics sections" do
    get analytics_path
    assert_response :success

    assert_includes response.body, "Juicerfeed Analytics"
    assert_includes response.body, "Top 5 Most Viewed Posts"
    assert_includes response.body, "Top Viewed Posts"
    assert_includes response.body, "Top Liked Posts"
    assert_includes response.body, "Top Commented Posts"
    assert_includes response.body, "Top Shared Posts"
  end
end
