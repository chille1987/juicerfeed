require "test_helper"

class FetchPostsFromApiTest < ActiveSupport::TestCase
  def build_connection(&block)
    stubs = Faraday::Adapter::Test::Stubs.new(&block)

    Faraday.new(url: MockendClient::BASE_URL, headers: MockendClient::DEFAULT_HEADERS) do |f|
      f.options.timeout = 10
      f.options.open_timeout = 3
      f.request  :json
      f.response :json
      f.response :raise_error
      f.adapter :test, stubs
    end
  end

  def logger
    @logger ||= Logger.new(StringIO.new)
  end

  def setup_sources
    Post.destroy_all
    Source.destroy_all

    @source_x = Source.create!(external_id: 1, platform: "x", username: "x_user")
    @source_i = Source.create!(external_id: 2, platform: "instagram", username: "insta_user")
  end

  test "Import posts from api and returns true on success" do
    setup_sources

    conn = build_connection do |stub|
      stub.get("/api/emirvatric/dev/posts") do
        [
          200,
          { "Content-Type" => "application/json" },
          [
            {
              "id" => 1, "sourceId" => 1, "comments" => 413, "content" => "Post one content", "hashtags" => "#music #vibes", "isPromoted" => false, "likes" => 4889, "location" => "Barcelona", "mediaType" => "carousel", "mediaUrl" => "https://picsum.photos/seed/8710/800/600", "mentions" => "@john_doe @jane_smith", "profileImage"=> "https://picsum.photos/seed/6944/400/400", "shares" => 135, "views" => 41819
            },
            {
              "id" => 2, "sourceId" => 2, "comments" => 24, "content" => "Post two content", "hashtags" => "#books #reading", "isPromoted" => false, "likes" => 4545, "location" => "Los Angeles", "mediaType" => "image", "mediaUrl" => "https://picsum.photos/seed/2062/800/600", "mentions" => "", "profileImage" => "https://picsum.photos/seed/6798/400/400", "shares" => 478, "views" => 15317
            }
          ].to_json
        ]
      end
    end

    client = MockendClient.new(conn: conn)
    service = FetchPostsFromApi.new(client: client, logger: logger)

    result = service.call
    assert_equal true, result
    assert_equal 2, Post.count

    post1 = Post.find_by(external_id: 1)
    post2 = Post.find_by(external_id: 2)

    assert_not_nil post1
    assert_not_nil post2
    assert_equal @source_x, post1.source
    assert_equal @source_i, post2.source
    assert_equal "Post one content", post1.content
    assert_equal "Post two content", post2.content
  end

  test "Retries on 500 then succeed" do
    setup_sources

    calls = 0
    conn = build_connection do |stub|
      stub.get("/api/emirvatric/dev/posts") do
        calls += 1

        if calls == 1
          [
            500,
            { "Content-Type" => "application/json" },
            { error: "server_error" }.to_json
          ]
        else
          [
            200,
            { "Content-Type" => "application/json" },
            [
              {
                "id" => 1, "sourceId" => 1, "comments" => 413, "content" => "Post retry one content", "hashtags" => "#music #vibes", "isPromoted" => false, "likes" => 4889, "location" => "Barcelona", "mediaType" => "carousel", "mediaUrl" => "https://picsum.photos/seed/8710/800/600", "mentions" => "@john_doe @jane_smith", "profileImage"=> "https://picsum.photos/seed/6944/400/400", "shares" => 135, "views" => 41819
              },
              {
                "id" => 2, "sourceId" => 2, "comments" => 24, "content" => "Post retry two content", "hashtags" => "#books #reading", "isPromoted" => false, "likes" => 4545, "location" => "Los Angeles", "mediaType" => "image", "mediaUrl" => "https://picsum.photos/seed/2062/800/600", "mentions" => "", "profileImage" => "https://picsum.photos/seed/6798/400/400", "shares" => 478, "views" => 15317
              }
            ].to_json
          ]
        end
      end
    end

    client = MockendClient.new(conn: conn)
    service = FetchPostsFromApi.new(client: client, logger: logger)
    result = service.call

    assert_equal true, result
    assert_equal 2, Post.count

    post1 = Post.find_by(external_id: 1)
    post2 = Post.find_by(external_id: 2)

    assert_not_nil post1
    assert_not_nil post2
    assert_equal @source_x, post1.source
    assert_equal @source_i, post2.source
    assert_equal "Post retry one content", post1.content
    assert_equal "Post retry two content", post2.content
  end

  test "Skip posts when sourceId doesn't match any local sources" do
    Source.destroy_all
    Post.destroy_all

    conn = build_connection do |stub|
      stub.get("/api/emirvatric/dev/posts") do
        [
          200,
          { "Content-Type" => "application/json" },
          [
            {
              "id" => 1, "sourceId" => 1, "comments" => 413, "content" => "Post retry one content", "hashtags" => "#music #vibes", "isPromoted" => false, "likes" => 4889, "location" => "Barcelona", "mediaType" => "carousel", "mediaUrl" => "https://picsum.photos/seed/8710/800/600", "mentions" => "@john_doe @jane_smith", "profileImage"=> "https://picsum.photos/seed/6944/400/400", "shares" => 135, "views" => 41819
            }
          ].to_json
        ]
      end
    end

    client = MockendClient.new(conn: conn)
    service = FetchPostsFromApi.new(client: client, logger: logger)
    result = service.call

    assert_equal true, result
    assert_equal 0, Post.count
  end
end
