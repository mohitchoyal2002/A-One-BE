class CreateRewardApplications < ActiveRecord::Migration[7.1]
  def change
    create_table :reward_applications do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title
      t.string :status, default: 'in_progress'

      t.timestamps
    end
  end
end
