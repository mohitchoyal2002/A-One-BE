class AddUsedToReceipts < ActiveRecord::Migration[7.1]
  def up
    add_column :receipts, :used, :boolean, default: false, null: false

    # Backfill: mark receipts as used if they have an approved reward application
    execute <<-SQL
      UPDATE receipts
      SET used = 1
      WHERE receipt_no IN (
        SELECT receipt_no FROM reward_applications WHERE status = 'approved'
      )
    SQL
  end

  def down
    remove_column :receipts, :used
  end
end
