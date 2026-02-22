module Api
  module V1
    class BaseApiController < ApplicationController
      skip_before_action :verify_authenticity_token

      # --- Global Exception Handlers ---

      rescue_from ActiveRecord::RecordNotFound do |e|
        model = e.model&.underscore&.humanize || 'Record'
        render json: { error: "#{model} not found" }, status: :not_found
      end

      rescue_from ActiveRecord::RecordInvalid do |e|
        render json: { error: e.record.errors.full_messages.join(', ') }, status: :unprocessable_entity
      end

      rescue_from ActiveRecord::RecordNotDestroyed do |e|
        render json: { error: "Unable to delete record: #{e.record.errors.full_messages.join(', ')}" }, status: :unprocessable_entity
      end

      rescue_from ActionController::ParameterMissing do |e|
        render json: { error: "Missing required parameter: #{e.param}" }, status: :bad_request
      end

      rescue_from ArgumentError do |e|
        render json: { error: "Invalid argument: #{e.message}" }, status: :bad_request
      end

      rescue_from StandardError do |e|
        Rails.logger.error "[API Error] #{e.class}: #{e.message}\n#{e.backtrace&.first(5)&.join("\n")}"
        render json: { error: 'An unexpected error occurred. Please try again.' }, status: :internal_server_error
      end
    end
  end
end
