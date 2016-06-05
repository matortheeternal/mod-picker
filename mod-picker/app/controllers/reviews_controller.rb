class ReviewsController < ContributionsController
  before_action :set_review, only: [:show, :update, :approve, :hide, :destroy]

  # GET /reviews
  def index
    @reviews = Review.filter(filtering_params)

    render :json => @reviews
  end

  # PATCH/PUT /reviews/1
  def update
    authorize! :update, @contribution
    @contribution.clear_ratings
    if @contribution.update(contribution_update_params)
      render json: {status: :ok}
    else
      render json: @contribution.errors, status: :unprocessable_entity
    end
  end

  # POST /reviews
  def create
    @review = Review.new(contribution_params)
    @review.submitted_by = current_user.id
    authorize! :create, @review

    if @review.save
      render json: {status: :ok}
    else
      render json: @review.errors, status: :unprocessable_entity
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_review
      @contribution = Review.find(params[:id])
    end

    # Params we allow filtering on
    def filtering_params
      params.slice(:mod, :by);
    end

    # Params allowed during creation
    def contribution_params
      params.require(:review).permit(:mod_id, :game_id, :text_body, (:moderator_message if current_user.can_moderate?), review_ratings_attributes: [:rating, :review_section_id])
    end

    # Params that can be updated
    def contribution_update_params
      params.require(:review).permit(:text_body, :edit_summary, (:moderator_message if current_user.can_moderate?), review_ratings_attributes: [:rating, :review_section_id])
    end
end
