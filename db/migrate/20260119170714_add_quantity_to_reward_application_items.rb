class AddQuantityToRewardApplicationItems < ActiveRecord::Migration[7.1]
  def change
    add_column :reward_application_items, :quantity, :integer, default: 1
  end
end
