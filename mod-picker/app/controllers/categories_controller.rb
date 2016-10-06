class CategoriesController < ApplicationController
  # GET /categories
  def index
    respond_with(Category.all, :base)
  end
end
