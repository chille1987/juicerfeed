require "test_helper"

class SourceTest < ActiveSupport::TestCase
  test "Valid with platform and username" do
    source = Source.new(platform: "Facebook", username: "techguru")
    assert source.valid?
  end

  test "Not valid without platform" do
    source = Source.new(username: "techguru")
    assert_not source.valid?
  end

  test "Not valid without username" do
    source = Source.new(platform: "Facebook")
    assert_not source.valid?
  end

  test "Normalize strips and downcases" do
    source = Source.new(platform: "Facebook", username: "Techguru")
    source.valid?

    assert_equal "facebook", source.platform
    assert_equal "techguru", source.username
  end

  test "Scope uniqueness on (platform, username)" do
    source1 = Source.create!(platform: "Facebook", username: "techguru")
    source2 = Source.new(platform: "Facebook", username: "Techguru")

    assert source1.valid?
    assert_not source2.valid?
  end

  test "Valid with same username and different platform" do
    source1 = Source.create!(platform: "Facebook", username: "techguru")
    source2 = Source.create!(platform: "Instagram", username: "techguru")

    assert source1.valid?
    assert source2.valid?
  end
end
