module Retryable
  extend ActiveSupport::Concern

  RETRYABLE_STATUSES = [ 429, 500 ].freeze
  MAX_RETRIES = 3
  BASE_BACKOFF = 1.0

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
end
