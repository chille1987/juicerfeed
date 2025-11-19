class FetchSourcesFromApi
  RETRYABLE_STATUSES = [ 429, 500 ].freeze
  MAX_RETRIES = 3
  BASE_BACKOFF = 1.0 # Seconds

  def self.call = new.call

  def initialize(client: MockendClient.new, logger: Rails.logger)
    @client = client
    @logger = logger
  end

  def call
    rows = with_retries do
      @client.get("/api/emirvatric/dev/sources")
    end

    return false unless rows.is_a?(Array)

    import_sources(rows)
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
      @logger.warn("Retrying to fetch sources after #{status}, (attempt #{attempts}/#{max_attempts}) in #{sleep_seconds}s ")

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

  def import_sources(rows)
    rows.each do |row|
      api_id = row["id"]
      platform = row["platform"]
      username = row["username"]

      if platform.blank? or username.blank?
        @logger.warn("Missing data: #{row.inspect}")
        next
      end

      begin
        if api_id.present?
          Source.find_or_create_by!(external_id: api_id) do |source|
            source.platform = platform
            source.username = username
          end
        else
          Source.find_or_create_by!(platform:, username:)
        end
      rescue ActiveRecord::RecordNotUnique
        next
      end
    end
  end
end
