class CreateReceipts < ActiveRecord::Migration[7.1]
  def change
    create_table :receipts do |t|
      t.string :receipt_no, null: false
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.datetime :date
      t.text :description

      t.timestamps
    end

    add_index :receipts, :receipt_no, unique: true
  end
end
