ActiveAdmin.register RewardApplication do
  permit_params :status

  actions :index, :show, :edit, :update

  scope :all
  scope :pending, default: true
  scope :approved
  scope :rejected

  filter :user
  filter :receipt_no
  filter :status, as: :select, collection: %w[pending approved rejected]
  filter :auto_approved
  filter :auto_rejected
  filter :created_at

  index do
    selectable_column
    id_column
    column :user
    column :receipt_no
    column :receipt_amount do |ra|
      number_to_currency ra.receipt_amount, unit: '₹'
    end
    column :points_to_earn
    column :status do |ra|
      status_tag ra.status, class: case ra.status
                                    when 'approved' then 'ok'
                                    when 'rejected' then 'error'
                                    else 'warning'
                                    end
    end
    column :auto_approved
    column :auto_rejected
    column :created_at
    actions defaults: true do |ra|
      if ra.status == 'pending'
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
      row :receipt_no
      row :receipt_amount do |ra|
        number_to_currency ra.receipt_amount, unit: '₹'
      end
      row :points_to_earn
      row :status do |ra|
        status_tag ra.status, class: case ra.status
                                      when 'approved' then 'ok'
                                      when 'rejected' then 'error'
                                      else 'warning'
                                      end
      end
      row :auto_approved
      row :auto_rejected
      row :rejection_reason
      row :processed_at
      row :created_at
      row :updated_at
    end

    # Show legacy items if any exist
    if reward_application.reward_application_items.any?
      panel "Legacy Items" do
        table_for reward_application.reward_application_items do
          column :product
          column :quantity
          column :price
          column :total_price
        end
      end
    end
  end

  member_action :approve, method: :put do
    receipt = Receipt.find_by(receipt_no: resource.receipt_no)
    if receipt && resource.receipt_amount.to_f == 0
      points = ((receipt.amount / 100).floor * 10).to_i
      resource.update!(
        status: 'approved',
        receipt_amount: receipt.amount,
        points_to_earn: points,
        processed_at: Time.current
      )
    else
      points = resource.points_to_earn > 0 ? resource.points_to_earn : resource.calculate_earnable_points
      resource.update!(
        status: 'approved',
        points_to_earn: points,
        processed_at: Time.current
      )
    end
    redirect_to resource_path, notice: "Application approved! #{points} points awarded."
  end

  member_action :reject, method: :put do
    resource.update!(
      status: 'rejected',
      processed_at: Time.current,
      rejection_reason: 'Manually rejected by admin'
    )
    redirect_to resource_path, notice: "Application rejected!"
  end

  action_item :approve, only: :show do
    link_to "Approve", approve_admin_reward_application_path(resource), method: :put if resource.status == 'pending'
  end

  action_item :reject, only: :show do
    link_to "Reject", reject_admin_reward_application_path(resource), method: :put if resource.status == 'pending'
  end
end
