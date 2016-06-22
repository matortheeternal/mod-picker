class ReviewsController < ContributionsController
  before_action :set_review, only: [:show, :update, :approve, :hide, :destroy]

  # GET /reviews
  def index
    @reviews = Review.accessible_by(current_ability).filter(filtering_params).sort(params[:sort]).paginate(:page => params[:page])

    render :json => @reviews
  end

  # PATCH/PUT /reviews/1
  def update
    authorize! :update, @contribution
    @contribution.clear_ratings

    update_params = contribution_update_params
    update_params[:edited_by] = current_user.id
    if @contribution.update(update_params)
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

  # NOT CORRECTABLE
  def corrections
    render status: 404
  end

  # NOT HISTORICAL
  def history
    render status: 404
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
