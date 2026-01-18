class User < ApplicationRecord
  has_secure_password

  validates :full_name, presence: true
  validates :phone_number, presence: true, uniqueness: true
  validates :address, presence: true
  validates :email, uniqueness: true, allow_nil: true, allow_blank: true
end
