class Feedback < ApplicationRecord
  belongs_to :user
  validates :subject, presence: true
  validates :email, presence: true
  validates :message, presence: true
end
