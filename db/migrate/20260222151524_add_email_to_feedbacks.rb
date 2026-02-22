class AddEmailToFeedbacks < ActiveRecord::Migration[7.1]
  def change
    add_column :feedbacks, :email, :string
  end
end
