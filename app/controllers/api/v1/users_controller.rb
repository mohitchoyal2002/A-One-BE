module Api
  module V1
    class UsersController < BaseApiController

      def show
        user = User.find(params[:id])
        render json: user
      end

      def update
        user = User.find(params[:id])
        if user.update(user_params)
          render json: { message: 'Profile updated successfully', user: user }
        else
          render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def user_params
        params.permit(:full_name, :phone_number, :email, :address)
      end
    end
  end
end
