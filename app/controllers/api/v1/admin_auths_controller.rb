module Api
  module V1
    class AdminAuthsController < BaseApiController

      def signin
        admin_user = AdminUser.find_by(email: params[:email])

        if admin_user&.valid_password?(params[:password])
          render json: {
            admin: {
              id: admin_user.id,
              email: admin_user.email,
            },
            message: 'Admin login successful'
          }
        else
          render json: { error: 'Invalid email or password' }, status: :unauthorized
        end
      end
    end
  end
end
