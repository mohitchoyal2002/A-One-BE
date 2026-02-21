class RewardApplicationItem < ApplicationRecord
  belongs_to :reward_application
  belongs_to :product

  validates :price, presence: true
  validates :quantity, presence: true, numericality: { greater_than: 0 }

  def total_price
    price * quantity
  end
end
