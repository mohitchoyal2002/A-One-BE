class CreateRewardApplicationItems < ActiveRecord::Migration[7.1]
  def change
    create_table :reward_application_items do |t|
      t.references :reward_application, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.decimal :price, precision: 10, scale: 2

      t.timestamps
    end
  end
end
