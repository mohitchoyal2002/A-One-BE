module Api
  module V1
    class RewardApplicationsController < BaseApiController
      before_action :set_user

      def index
        @reward_applications = @user.reward_applications.order(created_at: :desc)
        render json: @reward_applications.as_json(
          only: [:id, :user_id, :title, :status, :receipt_no, :receipt_amount, :points_to_earn,
                 :auto_approved, :auto_rejected, :rejection_reason, :processed_at, :created_at]
        )
      end

      def create
        receipt_no = reward_application_params[:receipt_no]

        # Validate receipt_no presence
        if receipt_no.blank?
          render json: { error: 'Receipt number is required' }, status: :unprocessable_entity and return
        end

        # Check if receipt is already marked as used
        receipt = Receipt.find_by(receipt_no: receipt_no)
        if receipt&.used?
          render json: { error: 'This receipt has already been redeemed' }, status: :bad_request and return
        end

        # Check for duplicate submission by ANY user (not yet rejected)
        existing = RewardApplication.where(receipt_no: receipt_no).where.not(status: 'rejected').first
        if existing
          render json: { error: 'This receipt has already been submitted for rewards' }, status: :bad_request and return
        end

        # Look up receipt for immediate info
        receipt_amount = receipt ? receipt.amount : 0
        points_to_earn = receipt ? ((receipt.amount / 100).floor * 10) : 0

        @reward_application = @user.reward_applications.new(
          title: "Receipt Redemption - #{receipt_no}",
          receipt_no: receipt_no,
          receipt_amount: receipt_amount,
          points_to_earn: points_to_earn,
          status: 'pending'
        )

        if @reward_application.save
          render json: @reward_application.as_json(
            only: [:id, :user_id, :title, :status, :receipt_no, :receipt_amount, :points_to_earn, :created_at]
          ), status: :created
        else
          render json: { errors: @reward_application.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def set_user
        if params[:user_id].present?
          @user = User.find(params[:user_id])
        elsif params[:reward_application] && params[:reward_application][:user_id]
          @user = User.find(params[:reward_application][:user_id])
        else
          render json: { error: 'User ID is required' }, status: :unauthorized and return
        end
      end

      def reward_application_params
        params.require(:reward_application).permit(:receipt_no, :user_id)
      end
    end
  end
end
