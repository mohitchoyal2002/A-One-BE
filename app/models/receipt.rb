class Receipt < ApplicationRecord
  validates :receipt_no, presence: true, uniqueness: true
  validates :amount, presence: true, numericality: { greater_than: 0 }

  scope :available, -> { where(used: false) }

  def mark_as_used!
    update!(used: true)
  end

  def self.ransackable_attributes(auth_object = nil)
    ["amount", "created_at", "date", "description", "id", "receipt_no", "updated_at", "used"]
  end
end
