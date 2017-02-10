class Api::V1::CategoryPrioritiesController < Api::ApiController
  # GET /category_priorities.json
  def index
    render json: CategoryPriority.all
  end
end
