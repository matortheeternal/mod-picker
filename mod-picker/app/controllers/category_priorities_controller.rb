class CategoryPrioritiesController < ApplicationController
  # GET /category_priorities
  # GET /category_priorities.json
  def index
    @category_priorities = CategoryPriority.all

    respond_to do |format|
      format.html
      format.json { render :json => @category_priorities}
    end
  end
end
