class RewardApplication < ApplicationRecord
  belongs_to :user
  has_many :reward_application_items, dependent: :destroy
  has_many :products, through: :reward_application_items
  accepts_nested_attributes_for :reward_application_items

  scope :pending, -> { where(status: 'pending') }
  scope :in_progress, -> { where(status: 'in_progress') }
  scope :approved, -> { where(status: 'approved') }
  scope :rejected, -> { where(status: 'rejected') }

  def self.ransackable_attributes(auth_object = nil)
    ["created_at", "id", "status", "title", "updated_at", "user_id", "receipt_no", "receipt_amount", "points_to_earn", "auto_approved", "auto_rejected"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["user", "reward_application_items", "products"]
  end

  validates :status, inclusion: { in: %w[pending in_progress approved rejected] }

  after_save :update_user_points, if: :saved_change_to_status?

  def total_amount
    if receipt_amount.present? && receipt_amount > 0
      receipt_amount
    else
      reward_application_items.sum { |item| item.price * item.quantity }
    end
  end

  def calculate_earnable_points
    (total_amount / 100).floor * 10
  end

  private

  def update_user_points
    points = points_to_earn.present? && points_to_earn > 0 ? points_to_earn : calculate_earnable_points
    if status == 'approved'
      user.increment!(:reward_points, points)
    elsif saved_change_to_status? && saved_change_to_status[0] == 'approved'
      # Was approved, now it's not (rejected or back to pending)
      user.decrement!(:reward_points, points)
    end
  end
end
