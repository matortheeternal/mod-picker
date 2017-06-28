class Api::V1::CategoriesController < Api::ApiController
  # GET /categories
  def index
    render json: static_cache("categories") {
      Category.all.to_json
    }
  end
end
