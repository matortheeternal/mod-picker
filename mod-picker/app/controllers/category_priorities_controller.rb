class CategoryPrioritiesController < ApplicationController
  # GET /category_priorities.json
  def index
    respond_with(CategoryPriority.all, :base)
  end
end
