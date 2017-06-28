class CategoriesController < ApplicationController
  # GET /categories
  def index
    render json: static_cache("categories") {
      Category.all.to_json
    }
  end

  # GET /categories/chart
  def chart
    render json: static_cache("categories/chart") {
      Category.chart.to_json
    }
  end
end
