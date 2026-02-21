ActiveAdmin.register RewardApplication do
  permit_params :status

  actions :index, :show, :edit, :update

  scope :all
  scope :in_progress, default: true
  scope :approved
  scope :rejected

  filter :user
  filter :status, as: :select, collection: %w[in_progress approved rejected]
  filter :created_at

  index do
    selectable_column
    id_column
    column :user
    column :title
    column :total_amount do |ra|
      number_to_currency ra.total_amount
    end
    column :status
    column :created_at
    actions defaults: true do |ra|
      if ra.status == 'in_progress'
        item "Approve", approve_admin_reward_application_path(ra), method: :put, class: "member_link"
        item "Reject", reject_admin_reward_application_path(ra), method: :put, class: "member_link"
      end
    end
  end

  show do
    attributes_table do
      row :id
      row :user
      row :title
      row :status
      row :total_amount do |ra|
        number_to_currency ra.total_amount
      end
      row :created_at
      row :updated_at
    end

    panel "Items" do
      table_for reward_application.reward_application_items do
        column :product
        column :quantity
        column :price
        column :total_price
      end
    end
  end

  member_action :approve, method: :put do
    resource.update!(status: 'approved')
    redirect_to resource_path, notice: "Application approved!"
  end

  member_action :reject, method: :put do
    resource.update!(status: 'rejected')
    redirect_to resource_path, notice: "Application rejected!"
  end

  action_item :approve, only: :show do
    link_to "Approve", approve_admin_reward_application_path(resource), method: :put if resource.status == 'in_progress'
  end

  action_item :reject, only: :show do
    link_to "Reject", reject_admin_reward_application_path(resource), method: :put if resource.status == 'in_progress'
  end
end
