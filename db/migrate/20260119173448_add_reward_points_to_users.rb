class AddRewardPointsToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :reward_points, :integer, default: 100
  end
end
