require "faraday"
require "json"

class MockendClient
  BASE_URL = "https://mockend.com/"
  DEFAULT_HEADERS = {
    "Accept" => "application/json",
    "User-Agent" => "MockendClient (Faraday)"
  }.freeze

  def initialize(conn: nil)
    @conn = conn || build_connection
  end

  def get(path, params: {}, headers: {})
    resp = @conn.get(path, params) do |req|
      req.headers.update(headers) if headers && !headers.empty?
    end

    resp.body
  end

  private

  def build_connection
    Faraday.new(url: BASE_URL, headers: DEFAULT_HEADERS) do |f|
      f.options.timeout = 10
      f.options.open_timeout = 3
      f.request :json
      f.response :json
      f.response :raise_error
    end
  end
end
