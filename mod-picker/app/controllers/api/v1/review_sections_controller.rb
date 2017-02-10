class Api::V1::ReviewSectionsController < Api::ApiController
  # GET /review_sections
  def index
    render json: ReviewSection.all
  end
end