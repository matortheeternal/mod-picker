class CategoryPrioritiesController < ApplicationController
  # GET /category_priorities.json
  def index
    render json: CategoryPriority.all
  end
end
