class FetchPostsFromApi
  RETRYABLE_STATUSES = [ 429, 500 ].freeze
  MAX_RETRIES = 3
  BASE_BACKOFF = 1.0

  def self.call = new.call

  def initialize(client: MockendClient.new, logger: Rails.logger)
    @client = client
    @logger = logger
  end

  def call
    rows = with_retries do
      @client.get("/api/emirvatric/dev/posts")
    end

    return false unless rows.is_a?(Array)

    import_posts(rows)
    true
  rescue Faraday::Error => e
    status = e.response && e.response[:status]
    @logger.warn("Faraday error: #{e.class} status=#{status}")
    false
  rescue JSON::ParserError => e
    @logger.warn("JSON parse error: #{e.message}")
    false
  rescue => e
    @logger.warn("Unexpected error: #{e.class}: #{e.message}")
    false
  end

  private

  def with_retries(max_attempts: MAX_RETRIES)
    attempts = 0

    begin
      attempts += 1
      yield
    rescue Faraday::Error => e
      status  = e.response && e.response[:status]
      headers = e.response && e.response[:headers]

      unless retryable_status?(status) && attempts < max_attempts
        raise
      end

      sleep_seconds = sleep_duration_for(status, headers, attempts)
      @logger.warn("Retrying to fetch posts after #{status}, (attempt #{attempts}/#{max_attempts}) in #{sleep_seconds}s ")

      sleep(sleep_seconds)
      retry
    end
  end

  def retryable_status?(status)
    RETRYABLE_STATUSES.include?(status)
  end

  def sleep_duration_for(status, headers, attempts)
    if status == 429
      retry_after_seconds(headers) || backoff_for_attempt(attempts)
    else
      backoff_for_attempt(attempts)
    end
  end

  def retry_after_seconds(headers)
    return nil unless headers

    raw = headers["Retry-After"] || headers["retry-after"]
    return nil if raw.nil?

    Integer(raw)
  rescue ArgumentError, TypeError
    nil
  end

  def backoff_for_attempt(attempts)
    BASE_BACKOFF * (2 ** (attempts - 1))
  end

  def import_posts(rows)
    rows.each do |row|
      api_post_id = row["id"]
      api_source_id = row["sourceId"]

      if api_post_id.blank? or api_source_id.blank?
        @logger.warn("Missing data: #{row.inspect}")
        next
      end

      source = Source.find_by(external_id: api_source_id)
      unless source
        @logger.warn("No local source for sourceId=#{api_source_id}")
        next
      end

      begin
        Post.find_or_create_by!(external_id: api_post_id) do |post|
          post.source = source
          post.comments = row["comments"] || 0
          post.content = row["content"]
          post.hashtags = row["hashtags"]
          post.is_promoted = row["isPromoted"]
          post.likes = row["likes"] || 0
          post.location = row["location"]
          post.media_type = row["mediaType"]
          post.media_url = row["mediaUrl"]
          post.mentions = row["mentions"]
          post.profile_image = row["profileImage"]
          post.shares = row["shares"] || 0
          post.views = row["views"] || 0
        end
      rescue ActiveRecord::RecordInvalid => e
        @logger.warn("Invalid post for external_id=#{api_post_id}")
      rescue ActiveRecord::RecordNotUnique
        next
      end
    end
  end
end
