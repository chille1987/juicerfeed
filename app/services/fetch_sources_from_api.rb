class FetchSourcesFromApi
  include Retryable

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
