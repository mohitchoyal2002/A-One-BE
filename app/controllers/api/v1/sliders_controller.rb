module Api
  module V1
    class SlidersController < BaseApiController
      # GET /api/v1/sliders
      def index
        sliders = SliderImage.active.ordered
        render json: sliders.as_json(only: [:id, :image_url, :title, :position])
      end
    end
  end
end
