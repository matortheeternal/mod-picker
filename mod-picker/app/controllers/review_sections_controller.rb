class ReviewSectionsController < ApplicationController
  # GET /review_sections
  def index
    render json: ReviewSection.all
  end
end