class RewardApplication < ApplicationRecord
  belongs_to :user
  has_many :reward_application_items, dependent: :destroy
  has_many :products, through: :reward_application_items
  accepts_nested_attributes_for :reward_application_items

  scope :in_progress, -> { where(status: 'in_progress') }
  scope :approved, -> { where(status: 'approved') }
  scope :rejected, -> { where(status: 'rejected') }

  def self.ransackable_attributes(auth_object = nil)
    ["created_at", "id", "status", "title", "updated_at", "user_id"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["user", "reward_application_items", "products"]
  end

  validates :title, presence: true
  validates :status, inclusion: { in: %w[in_progress approved rejected] }

  after_save :update_user_points, if: :saved_change_to_status?

  def total_amount
    reward_application_items.sum { |item| item.price * item.quantity }
  end

  def calculate_earnable_points
    (total_amount / 100).floor * 10
  end

  private

  def update_user_points
    points = calculate_earnable_points
    if status == 'approved'
      user.increment!(:reward_points, points)
    elsif saved_change_to_status? && saved_change_to_status[0] == 'approved'
      # Was approved, now it's not (rejected or back to in_progress)
      user.decrement!(:reward_points, points)
    end
  end
end
