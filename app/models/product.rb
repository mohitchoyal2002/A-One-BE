class Product < ApplicationRecord
  has_many :reward_application_items
  has_many :product_images, dependent: :destroy
  accepts_nested_attributes_for :product_images, allow_destroy: true

  def self.ransackable_attributes(auth_object = nil)
    ["created_at", "description", "discount", "id", "name", "price", "updated_at"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["product_images"]
  end
end
