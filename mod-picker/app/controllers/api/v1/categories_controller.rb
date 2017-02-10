class Api::V1::CategoriesController < Api::ApiController
  # GET /categories
  def index
    render json: Category.all
  end
end
