ActiveAdmin.register Receipt do
  permit_params :receipt_no, :amount, :date, :description

  filter :receipt_no
  filter :amount
  filter :date
  filter :created_at

  index do
    selectable_column
    id_column
    column :receipt_no
    column :amount do |r|
      number_to_currency r.amount, unit: '₹'
    end
    column :date
    column :description
    column :created_at
    actions
  end

  show do
    attributes_table do
      row :id
      row :receipt_no
      row :amount do |r|
        number_to_currency r.amount, unit: '₹'
      end
      row :date
      row :description
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.inputs do
      f.input :receipt_no
      f.input :amount
      f.input :date, as: :datepicker
      f.input :description
    end
    f.actions
  end

  # CSV Import action
  collection_action :import_csv, method: [:get, :post] do
    if request.post?
      if params[:csv_file].blank?
        redirect_to collection_path, alert: "Please select a CSV file."
        return
      end

      require 'csv'
      file = params[:csv_file]
      imported = 0
      errors = []

      CSV.foreach(file.path, headers: true) do |row|
        receipt_no = row['receipt_no']&.strip
        if receipt_no.blank?
          errors << "Row #{$.}: Missing receipt_no"
          next
        end

        if Receipt.exists?(receipt_no: receipt_no)
          errors << "Row #{$.}: Receipt #{receipt_no} already exists"
          next
        end

        begin
          Receipt.create!(
            receipt_no: receipt_no,
            amount: row['amount'].to_f,
            date: row['date'].present? ? DateTime.parse(row['date']) : Time.current,
            description: row['description']&.strip
          )
          imported += 1
        rescue => e
          errors << "Row #{$.}: #{e.message}"
        end
      end

      message = "Imported #{imported} receipts."
      message += " Errors: #{errors.join('; ')}" if errors.any?
      redirect_to collection_path, notice: message
    else
      render inline: <<-HTML
        <h2>Import Receipts from CSV</h2>
        <p>CSV should have columns: receipt_no, amount, date (optional), description (optional)</p>
        <form action="#{import_csv_admin_receipts_path}" method="post" enctype="multipart/form-data">
          <input type="hidden" name="authenticity_token" value="#{form_authenticity_token}">
          <input type="file" name="csv_file" accept=".csv">
          <br><br>
          <input type="submit" value="Import">
        </form>
      HTML
    end
  end

  action_item :import_csv, only: :index do
    link_to "Import CSV", import_csv_admin_receipts_path
  end
end
