require 'csv'

module Api
  module V1
    class AdminController < BaseApiController

      # GET /api/v1/admin/stats
      def stats
        render json: {
          total_products: Product.count,
          total_users: User.count,
          pending_requests: RewardApplication.where(status: 'pending').count,
          approved_requests: RewardApplication.where(status: 'approved').count,
          rejected_requests: RewardApplication.where(status: 'rejected').count,
          total_receipts: Receipt.count,
        }
      end

      # GET /api/v1/admin/users
      def users
        users = User.all.order(created_at: :desc)
        render json: users.as_json(only: [:id, :full_name, :email, :phone_number, :address, :reward_points, :created_at])
      end

      # GET /api/v1/admin/feedbacks
      def feedbacks
        feedbacks = Feedback.includes(:user).order(created_at: :desc)
        render json: feedbacks.map { |f|
          f.as_json(only: [:id, :subject, :message, :status, :created_at, :email])
           .merge(user_name: f.user&.full_name, user_email: f.email.presence || f.user&.email, user_phone: f.user&.phone_number)
        }
      end

      # PUT /api/v1/admin/users/:id
      def update_user
        user = User.find(params[:id])
        user.update!(
          full_name: params[:full_name],
          email: params[:email],
          phone_number: params[:phone_number],
          address: params[:address],
          reward_points: params[:reward_points]
        )
        render json: user.as_json(only: [:id, :full_name, :email, :phone_number, :address, :reward_points, :created_at])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'User not found' }, status: :not_found
      rescue ActiveRecord::RecordInvalid => e
        render json: { error: e.record.errors.full_messages.join(', ') }, status: :unprocessable_entity
      end

      # DELETE /api/v1/admin/users/:id
      def destroy_user
        user = User.find(params[:id])
        user.destroy!
        render json: { message: 'User deleted' }
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'User not found' }, status: :not_found
      end

      # GET /api/v1/admin/reward_requests
      def reward_requests
        requests = RewardApplication.includes(:user).order(created_at: :desc)
        render json: requests.map { |r|
          r.as_json(only: [:id, :title, :status, :receipt_no, :receipt_amount, :points_to_earn,
                           :auto_approved, :auto_rejected, :rejection_reason, :processed_at, :created_at])
            .merge(user_name: r.user&.full_name, user_phone: r.user&.phone_number)
        }
      end

      # PUT /api/v1/admin/reward_requests/:id
      def update_reward_request
        request = RewardApplication.find(params[:id])
        new_status = params[:status]

        if new_status == 'approved'
          receipt = Receipt.find_by(receipt_no: request.receipt_no)
          if receipt && request.receipt_amount.to_f == 0
            points = ((receipt.amount / 100).floor * 10).to_i
            request.update!(
              status: 'approved',
              receipt_amount: receipt.amount,
              points_to_earn: points,
              processed_at: Time.current
            )
          else
            points = request.points_to_earn > 0 ? request.points_to_earn : 0
            request.update!(
              status: 'approved',
              points_to_earn: points,
              processed_at: Time.current
            )
          end
        elsif new_status == 'rejected'
          request.update!(
            status: 'rejected',
            processed_at: Time.current,
            rejection_reason: params[:reason] || 'Manually rejected by admin'
          )
        end

        render json: { message: "Request #{new_status}" }
      end

      # POST /api/v1/admin/receipts
      def create_receipt
        receipt_params = params.require(:receipt).permit(:receipt_no, :amount, :description)
        receipt = Receipt.new(receipt_params)
        receipt.date = Time.current

        if receipt.save
          render json: receipt.as_json, status: :created
        else
          render json: { error: receipt.errors.full_messages.join(', ') }, status: :unprocessable_entity
        end
      end

      # ---- Product Management ----

      # GET /api/v1/admin/products
      def products
        products = Product.includes(:product_images).order(created_at: :desc)
        render json: products.as_json(include: { product_images: { only: [:id, :image_url] } })
      end

      # POST /api/v1/admin/products
      def create_product
        product = Product.new(
          name: product_params[:name],
          description: product_params[:description],
          price: product_params[:price],
          discount: product_params[:discount] || 0,
          category: product_params[:category]
        )

        if product.save
          # Add images
          if params[:product][:image_urls].present?
            params[:product][:image_urls].each do |url|
              product.product_images.create!(image_url: url) if url.present?
            end
          end
          render json: product.as_json(include: { product_images: { only: [:id, :image_url] } }), status: :created
        else
          render json: { error: product.errors.full_messages.join(', ') }, status: :unprocessable_entity
        end
      end

      # PUT /api/v1/admin/products/:id
      def update_product
        product = Product.find(params[:id])
        product.update!(
          name: product_params[:name],
          description: product_params[:description],
          price: product_params[:price],
          discount: product_params[:discount] || 0,
          category: product_params[:category]
        )

        # Replace images if provided
        if params[:product][:image_urls].present?
          product.product_images.destroy_all
          params[:product][:image_urls].each do |url|
            product.product_images.create!(image_url: url) if url.present?
          end
        end

        render json: product.as_json(include: { product_images: { only: [:id, :image_url] } })
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Product not found' }, status: :not_found
      end

      # DELETE /api/v1/admin/products/:id
      def destroy_product
        product = Product.find(params[:id])
        product.destroy!
        render json: { message: 'Product deleted' }
      end

      # POST /api/v1/admin/products/import_csv
      def import_csv
        unless params[:file].present?
          render json: { error: 'No file provided' }, status: :bad_request
          return
        end

        file = params[:file]
        imported = 0
        errors = []

        begin
          csv_content = file.read
          CSV.parse(csv_content, headers: true, liberal_parsing: true) do |row|
            begin
              product = Product.create!(
                name: row['name']&.strip,
                description: row['description']&.strip,
                price: row['price'].to_f,
                discount: row['discount'].to_f,
                category: row['category']&.strip
              )

              # Parse images (separated by |)
              if row['images'].present?
                row['images'].split('|').each do |url|
                  product.product_images.create!(image_url: url.strip) if url.strip.present?
                end
              end

              imported += 1
            rescue => e
              errors << "Row '#{row['name']}': #{e.message}"
            end
          end
        rescue => e
          render json: { error: "CSV parsing error: #{e.message}" }, status: :unprocessable_entity
          return
        end

        render json: { imported: imported, errors: errors }
      end

      # POST /api/v1/admin/receipts/import_csv
      def import_receipts
        unless params[:file].present?
          render json: { error: 'No file provided' }, status: :bad_request
          return
        end

        file = params[:file]
        imported = 0
        skipped = 0
        errors = []

        begin
          csv_content = file.read
          CSV.parse(csv_content, headers: true, liberal_parsing: true) do |row|
            begin
              receipt_no = row['receipt_no']&.strip
              amount = row['amount']&.strip&.to_f
              description = row['description']&.strip

              if receipt_no.blank? || amount.nil? || amount <= 0
                errors << "Row '#{receipt_no}': Invalid receipt_no or amount"
                next
              end

              # Skip duplicates
              if Receipt.exists?(receipt_no: receipt_no)
                skipped += 1
                next
              end

              Receipt.create!(
                receipt_no: receipt_no,
                amount: amount,
                description: description,
                date: Time.current
              )
              imported += 1
            rescue => e
              errors << "Row '#{receipt_no}': #{e.message}"
            end
          end
        rescue => e
          render json: { error: "CSV parsing error: #{e.message}" }, status: :unprocessable_entity
          return
        end

        render json: { imported: imported, skipped: skipped, errors: errors }
      end

      # ---- Slider Management ----

      # GET /api/v1/admin/sliders
      def slider_images
        sliders = SliderImage.ordered
        render json: sliders.as_json(only: [:id, :image_url, :title, :position, :active, :created_at])
      end

      # POST /api/v1/admin/sliders
      def create_slider_image
        if params[:image].present?
          # File upload
          uploaded = params[:image]
          ext = File.extname(uploaded.original_filename).presence || '.jpg'
          filename = "slider_#{Time.current.to_i}_#{SecureRandom.hex(4)}#{ext}"
          dest = Rails.root.join('public', 'uploads', 'sliders', filename)
          FileUtils.mkdir_p(File.dirname(dest))
          File.open(dest, 'wb') { |f| f.write(uploaded.read) }
          image_url = "#{request.protocol}#{request.host_with_port}/uploads/sliders/#{filename}"
        elsif params[:image_url].present?
          image_url = params[:image_url]
        else
          render json: { error: 'Image file or URL is required' }, status: :unprocessable_entity and return
        end

        slider = SliderImage.new(
          image_url: image_url,
          title: params[:title],
          position: params[:position] || (SliderImage.maximum(:position) || 0) + 1,
          active: params[:active].nil? ? true : params[:active]
        )
        if slider.save
          render json: slider.as_json(only: [:id, :image_url, :title, :position, :active, :created_at]), status: :created
        else
          render json: { error: slider.errors.full_messages.join(', ') }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/admin/sliders/:id
      def destroy_slider_image
        slider = SliderImage.find(params[:id])
        slider.destroy!
        render json: { message: 'Slider image deleted' }
      end

      private

      def slider_params
        params.permit(:image_url, :title, :position, :active)
      end

      def product_params
        params.require(:product).permit(:name, :description, :price, :discount, :category, image_urls: [])
      end
    end
  end
end
