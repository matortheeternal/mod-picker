class CategoryPrioritiesController < ApplicationController
  # GET /category_priorities
  def index
    render json: static_cache("category_priorities") {
      CategoryPriority.all.to_json
    }
  end
end
