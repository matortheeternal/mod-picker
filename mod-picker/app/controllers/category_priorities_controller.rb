class CategoryPrioritiesController < ApplicationController
  before_action :set_category_priority, only: [:show, :edit, :update, :destroy]

  # GET /category_priorities
  # GET /category_priorities.json
  def index
    @category_priorities = CategoryPriority.all

    respond_to do |format|
      format.html
      format.json { render :json => @category_priorities}
    end
  end

  # GET /category_priorities/1
  # GET /category_priorities/1.json
  def show
    respond_to do |format|
      format.html
      format.json { render :json => @category_priority}
    end
  end

  # GET /category_priorities/new
  def new
    @category_priority = CategoryPriority.new
  end

  # GET /category_priorities/1/edit
  def edit
  end

  # POST /category_priorities
  # POST /category_priorities.json
  def create
    @category_priority = CategoryPriority.new(category_priority_params)

    respond_to do |format|
      if @category_priority.save
        format.html { redirect_to @category_priority, notice: 'Category priority was successfully created.' }
        format.json { render :show, status: :created, location: @category_priority }
      else
        format.html { render :new }
        format.json { render json: @category_priority.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /category_priorities/1
  # PATCH/PUT /category_priorities/1.json
  def update
    respond_to do |format|
      if @category_priority.update(category_priority_params)
        format.html { redirect_to @category_priority, notice: 'Category priority was successfully updated.' }
        format.json { render :show, status: :ok, location: @category_priority }
      else
        format.html { render :edit }
        format.json { render json: @category_priority.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /category_priorities/1
  # DELETE /category_priorities/1.json
  def destroy
    @category_priority.destroy
    respond_to do |format|
      format.html { redirect_to category_priorities_url, notice: 'Category priority was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_category_priority
      @category_priority = CategoryPriority.find_by(dominant_id: params[:dominant_id], recessive_id: params[:recessive_id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def category_priority_params
      params.require(:category_priority).permit(:dominant_id, :recessive_id)
    end
end
