module Api
  module V1
    class ProductsController < ApplicationController
      def index
        products = Product.includes(:product_images).all
        render json: products.as_json(include: :product_images)
      end

      def show
        product = Product.includes(:product_images).find(params[:id])
        render json: product.as_json(include: :product_images)
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Product not found' }, status: :not_found
      end
    end
  end
end
