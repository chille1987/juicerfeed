require "test_helper"

class FetchSourcesFromApiTest < ActiveSupport::TestCase
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

  test "Import sources and returns true on success" do
    Source.destroy_all

    conn = build_connection do |stub|
      stub.get("/api/emirvatric/dev/sources") do
        [
          200,
          { "Content-Type" => "application/json" },
          [
            { "id" => 1, "platform" => "x", "username" => "x_user" },
            { "id" => 2, "platform" => "facebook", "username" => "facebook_user" }
          ].to_json
        ]
      end
    end

    client = MockendClient.new(conn: conn)
    service = FetchSourcesFromApi.new(client: client, logger: logger)

    result = service.call
    assert_equal true, result
    assert_equal 2, Source.count
    assert_equal %w[x facebook].sort, Source.pluck(:platform).sort
    assert_equal %w[x_user facebook_user].sort, Source.pluck(:username).sort
    assert_equal [1, 2].sort, Source.pluck(:external_id).sort
  end

  test "retries on 500 then succeeds" do
    Source.destroy_all

    calls = 0
    conn  = build_connection do |stub|
      stub.get("/api/emirvatric/dev/sources") do
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
              { "id" => 1, "platform" => "x", "username" => "x_user" },
              { "id" => 2, "platform" => "facebook", "username" => "facebook_user" }
            ].to_json
          ]
        end
      end
    end

    client  = MockendClient.new(conn: conn)
    service = FetchSourcesFromApi.new(client: client, logger: logger)

    result = service.call

    assert_equal true, result
    assert_equal 2, Source.count
    assert_equal %w[x facebook], Source.pluck(:platform)
    assert_equal %w[x_user facebook_user], Source.pluck(:username)
  end

  test "retries on 429 using Retry-After header" do
    Source.destroy_all

    calls = 0
    conn  = build_connection do |stub|
      stub.get("/api/emirvatric/dev/sources") do
        calls += 1

        if calls == 1
          [
            429,
            { "Content-Type" => "application/json", "Retry-After" => "3" },
            { error: "rate_limit" }.to_json
          ]
        else
          [
            200,
            { "Content-Type" => "application/json" },
            [
              { "id" => 1, "platform" => "x", "username" => "x_user" },
              { "id" => 2, "platform" => "facebook", "username" => "facebook_user" }
            ].to_json
          ]
        end
      end
    end

    client = MockendClient.new(conn: conn)
    service = FetchSourcesFromApi.new(client: client, logger: logger)

    result = service.call

    assert_equal true, result
    assert_equal 2, Source.count
    assert_equal %w[x facebook], Source.pluck(:platform)
    assert_equal %w[x_user facebook_user], Source.pluck(:username)
  end
end
