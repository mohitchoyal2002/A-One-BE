module Api
  module V1
    class RewardApplicationsController < ApplicationController
      skip_before_action :verify_authenticity_token
      before_action :set_user

      def index
        @reward_applications = @user.reward_applications.includes(:reward_application_items)
        render json: @reward_applications.as_json(include: { reward_application_items: { methods: :total_price } })
      end

      def create
        @reward_application = @user.reward_applications.new(reward_application_params)

        if @reward_application.save
          render json: @reward_application, status: :created
        else
          render json: @reward_application.errors, status: :unprocessable_entity
        end
      end

      private

      def set_user
        if params[:user_id].present?
          @user = User.find(params[:user_id])
        else
           # Fallback for create if user_id is in body
           if params[:reward_application] && params[:reward_application][:user_id]
             @user = User.find(params[:reward_application][:user_id])
           elsif params[:user_id].nil? && action_name == 'create'
              # Try to find user_id in the root of params if passed directly?
              # Better to rely on strong params or explicit checks.
              # For now, let's assume it might be passed as a query param or body param handled by params.
              render json: { error: 'User ID is required' }, status: :unauthorized and return
           else
              render json: { error: 'User ID is required' }, status: :unauthorized and return
           end
        end
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'User not found' }, status: :not_found
      end

      def reward_application_params
        params.require(:reward_application).permit(
          :title,
          :user_id,
          reward_application_items_attributes: [:product_id, :price, :quantity]
        )
      end
    end
  end
end
