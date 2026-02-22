class User < ApplicationRecord
  has_many :reward_applications
  has_many :feedbacks, dependent: :destroy
  has_secure_password

  validates :full_name, presence: true
  validates :phone_number, presence: true, uniqueness: true
  validates :address, presence: true
  validates :email, uniqueness: true, allow_nil: true, allow_blank: true
  validates :reward_points, numericality: { greater_than_or_equal_to: 0 }
end
