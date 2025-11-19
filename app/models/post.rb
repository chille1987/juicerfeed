class Post < ApplicationRecord
  belongs_to :source

  MEDIA_TYPES = %w[text image video carousel].freeze

  before_validation :normalize_media_type!

  validates :source, presence: true
  validates :media_type, inclusion: { in: MEDIA_TYPES }
  validates :likes, :comments, :shares, :views, numericality: { greater_than_or_equal_to: 0 }
  validates :is_promoted, inclusion: { in: [ true, false ] }
  validates :external_id, uniqueness: true, allow_nil: true

  scope :recent, -> { order(created_at: :desc) }

  private

  def normalize_media_type!
    self.media_type = media_type.to_s.downcase.presence || "text"
  end
end
