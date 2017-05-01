class CategoriesController < ApplicationController
  # GET /categories
  def index
    render json: Category.all
  end

  # GET /categories/chart
  def chart
    render json: Category.chart
  end
end
