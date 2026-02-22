class CreateSliderImages < ActiveRecord::Migration[7.1]
  def change
    create_table :slider_images do |t|
      t.string :image_url, null: false
      t.string :title
      t.integer :position, default: 0
      t.boolean :active, default: true

      t.timestamps
    end
  end
end
