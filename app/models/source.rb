class Source < ApplicationRecord
  has_many :posts, dependent: :destroy
  before_validation :normalize!

  validates :platform, presence: true, length: { maximum: 20 }
  validates :username, presence: true, uniqueness: { scope: :platform }
  validates :external_id, uniqueness: true, allow_nil: true

  private

  def normalize!
    self.platform = platform.to_s.strip.downcase
    self.username = username.to_s.strip.downcase
  end
end
