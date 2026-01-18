module Api
  module V1
    class AuthsController < ApplicationController
      skip_before_action :verify_authenticity_token

      def signup
        user = User.new(user_params)
        if user.save
          render json: { message: 'User created successfully', user: user }, status: :created
        else
          render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def signin
        user = if params[:email].present?
                 User.find_by(email: params[:email])
               elsif params[:phone_number].present?
                 User.find_by(phone_number: params[:phone_number])
               end

        if user && user.authenticate(params[:password])
          render json: { message: 'Logged in successfully', user: user }, status: :ok
        else
          render json: { error: 'Invalid credentials' }, status: :unauthorized
        end
      end

      private

      def user_params
        params.permit(:full_name, :phone_number, :email, :password, :address)
      end
    end
  end
end
