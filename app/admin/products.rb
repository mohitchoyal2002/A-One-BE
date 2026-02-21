ActiveAdmin.register Product do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  # permit_params :name, :price, :discount, :description
  #
  # or
  #
  # permit_params do
  #   permitted = [:name, :price, :discount, :description]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end

  permit_params :name, :price, :discount, :description, product_images_attributes: [:id, :image_url, :_destroy]

  index do
    selectable_column
    id_column
    column :name
    column :price
    column :discount
    column :description
    column :created_at
    column :updated_at
    actions
  end

  filter :name
  filter :price
  filter :discount
  filter :created_at

  form do |f|
    f.inputs do
      f.input :name
      f.input :price
      f.input :discount
      f.input :description
    end
    f.inputs do
      f.has_many :product_images, heading: 'Images', allow_destroy: true, new_record: true do |a|
        a.input :image_url
      end
    end
    f.actions
  end
end
