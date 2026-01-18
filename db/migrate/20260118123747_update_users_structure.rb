class UpdateUsersStructure < ActiveRecord::Migration[7.1]
  def change
    remove_column :users, :username, :string
    add_column :users, :full_name, :string
    add_column :users, :phone_number, :string
    add_column :users, :address, :string
    add_index :users, :phone_number, unique: true
  end
end
