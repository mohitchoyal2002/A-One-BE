module Api
  module V1
    class ProductsController < BaseApiController
      def index
        products = Product.includes(:product_images).all
        render json: products.as_json(include: :product_images)
      end

      def show
        product = Product.includes(:product_images).find(params[:id])
        render json: product.as_json(include: :product_images)
      end
    end
  end
end
