class AddUsedToReceipts < ActiveRecord::Migration[7.1]
  def up
    add_column :receipts, :used, :boolean, default: false, null: false
  end

  def down
    remove_column :receipts, :used
  end
end
