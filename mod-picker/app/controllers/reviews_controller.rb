class ReviewsController < HelpfulableController
  before_action :set_review, only: [:show, :update, :destroy]

  # GET /reviews
  # GET /reviews.json
  def index
    @reviews = Review.filter(filtering_params)

    render :json => @reviews
  end

  # GET /reviews/1
  # GET /reviews/1.json
  def show
    authorize! :read, @review
    render :json => @review
  end

  # POST /reviews
  # POST /reviews.json
  def create
    @review = Review.new(review_params)
    authorize! :create, @review

    if @review.save
      render json: {status: :ok}
    else
      render json: @review.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /reviews/1
  # PATCH/PUT /reviews/1.json
  def update
    authorize! :update, @review
    if @review.update(review_params)
      render json: {status: :ok}
    else
      render json: @review.errors, status: :unprocessable_entity
    end
  end

  # DELETE /reviews/1
  # DELETE /reviews/1.json
  def destroy
    authorize! :destroy, @review
    if @review.destroy
      render json: {status: :ok}
    else
      render json: @review.errors, status: :unprocessable_entity
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
