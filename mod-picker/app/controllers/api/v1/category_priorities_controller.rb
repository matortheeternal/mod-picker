class Api::V1::CategoryPrioritiesController < Api::ApiController
  # GET /category_priorities.json
  def index
    render json: static_cache("category_priorities") {
      CategoryPriority.all.to_json
    }
  end
end
