class SliderImage < ApplicationRecord
  validates :image_url, presence: true

  scope :active, -> { where(active: true) }
  scope :ordered, -> { order(position: :asc, created_at: :desc) }

  def self.ransackable_attributes(auth_object = nil)
    ["active", "created_at", "id", "image_url", "position", "title", "updated_at"]
  end
end
