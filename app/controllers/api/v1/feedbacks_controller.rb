module Api
  module V1
    class FeedbacksController < BaseApiController
      before_action :set_user

      def create
        @feedback = @user.feedbacks.new(feedback_params)

        if @feedback.save
          render json: @feedback, status: :created
        else
          render json: { errors: @feedback.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def set_user
        if params[:user_id].present?
          @user = User.find(params[:user_id])
        elsif params[:feedback] && params[:feedback][:user_id]
          @user = User.find(params[:feedback][:user_id])
        else
          render json: { error: 'User ID is required' }, status: :unauthorized and return
        end
      end

      def feedback_params
        params.require(:feedback).permit(:user_id, :subject, :message, :email)
      end
    end
  end
end
