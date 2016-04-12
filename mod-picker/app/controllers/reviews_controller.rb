class ReviewsController < ApplicationController
  before_action :set_review, only: [:show, :update, :destroy]

  # GET /reviews
  # GET /reviews.json
  def index
    @reviews = Review.filter(filtering_params)

    respond_to do |format|
      format.json { render :json => @reviews}
    end
  end

  # GET /reviews/1
  # GET /reviews/1.json
  def show
    respond_to do |format|
      format.json { render :json => @review}
    end
  end

  # POST /reviews
  # POST /reviews.json
  def create
    @review = Review.new(review_params)

    respond_to do |format|
      if @review.save
        format.json { render :show, status: :created, location: @review }
      else
        format.json { render json: @review.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /reviews/1
  # PATCH/PUT /reviews/1.json
  def update
    respond_to do |format|
      if @review.update(review_params)
        format.json { render :show, status: :ok, location: @review }
      else
        format.json { render json: @review.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /reviews/1
  # DELETE /reviews/1.json
  def destroy
    @review.destroy
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_review
      @review = Review.find(params[:id])
    end

    # Params we allow filtering on
    def filtering_params
      params.slice(:mod, :by);
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def review_params
      params.require(:review).permit(:submitted_by, :mod_id, :hidden, :rating1, :rating2, :rating3, :rating4, :rating5, :submitted, :edited, :text_body)
    end
end
