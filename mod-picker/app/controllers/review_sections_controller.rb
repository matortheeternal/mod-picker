class ReviewSectionsController < ApplicationController
  # GET /review_sections
  def index
    render json: static_cache("review_sections") {
      ReviewSection.all.to_json
    }
  end
end