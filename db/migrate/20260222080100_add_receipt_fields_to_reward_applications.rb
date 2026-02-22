class AddReceiptFieldsToRewardApplications < ActiveRecord::Migration[7.1]
  def change
    add_column :reward_applications, :receipt_no, :string
    add_column :reward_applications, :receipt_amount, :decimal, precision: 10, scale: 2, default: 0
    add_column :reward_applications, :points_to_earn, :integer, default: 0
    add_column :reward_applications, :auto_approved, :boolean, default: false
    add_column :reward_applications, :auto_rejected, :boolean, default: false
    add_column :reward_applications, :rejection_reason, :string
    add_column :reward_applications, :processed_at, :datetime

    add_index :reward_applications, :receipt_no

    # Update existing 'in_progress' statuses to 'pending' for consistency
    reversible do |dir|
      dir.up do
        execute "UPDATE reward_applications SET status = 'pending' WHERE status = 'in_progress'"
      end
      dir.down do
        execute "UPDATE reward_applications SET status = 'in_progress' WHERE status = 'pending'"
      end
    end

    change_column_default :reward_applications, :status, 'pending'
  end
end
