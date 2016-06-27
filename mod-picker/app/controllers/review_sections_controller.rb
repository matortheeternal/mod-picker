class ReviewSectionsController < ApplicationController
  # GET /review_sections
  def index
    @review_sections = ReviewSection.all

    render :json => @review_sections
  end
end