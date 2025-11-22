class Post < ApplicationRecord
  belongs_to :source

  MEDIA_TYPES = %w[text image video carousel].freeze

  before_validation :normalize_media_type!
  validate :media_url_must_be_safe

  validates :source, presence: true
  validates :media_type, inclusion: { in: MEDIA_TYPES }
  validates :likes, :comments, :shares, :views, numericality: { greater_than_or_equal_to: 0 }
  validates :is_promoted, inclusion: { in: [ true, false ] }
  validates :external_id, uniqueness: true, allow_nil: true

  scope :recent, -> { order(created_at: :desc) }
  scope :feed_order, -> { order(is_promoted: :desc, created_at: :desc) }
  scope :by_media_type, ->(media_type) { where(media_type: media_type) if media_type.present? }
  scope :by_source_id, ->(source_id) { where(source_id: source_id) if source_id.present? }
  scope :by_platform, ->(platform) {
    return all if platform.blank?

    joins(:source).where(sources: { platform: platform })
  }

  private

  def normalize_media_type!
    self.media_type = media_type.to_s.downcase.presence || "text"
  end

  def media_url_must_be_safe
    return if media_url.blank?

    uri = URI.parse(media_url)

    unless uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
      errors.add(:media_url, "must be a valid http(s) URL")
    end
  rescue URI::InvalidURIError
    errors.add(:media_url, "must be a valid http(s) URL")
  end
end
