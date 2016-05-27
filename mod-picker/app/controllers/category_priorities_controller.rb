class CategoryPrioritiesController < ApplicationController
  # GET /category_priorities
  # GET /category_priorities.json
  def index
    @category_priorities = CategoryPriority.all

    render :json => @category_priorities
  end
end
