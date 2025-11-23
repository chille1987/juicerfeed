class FetchPostsJob < ApplicationJob
  queue_as :default

  retry_on Faraday::TimeoutError, Faraday::ConnectionFailed, wait: 10.seconds, attempts: 3
  retry_on JSON::ParserError, wait: 5.seconds, attempts: 2
  def perform(*_args)
    FetchSourcesFromApi.call
    FetchPostsFromApi.call
  end
end
