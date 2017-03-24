class ReviewsController < ContributionsController
  before_action :set_review, only: [:show, :update, :approve, :hide, :destroy]

  # GET /reviews
  def index
    # prepare reviews
    @reviews = Review.preload(:review_ratings).includes(:mod).eager_load({submitter: :reputation}, :editor).accessible_by(current_ability).filter(filtering_params).sort(params[:sort]).paginate(page: params[:page])
    count = Review.eager_load({submitter: :reputation}, :editor).accessible_by(current_ability).filter(filtering_params).count

    # prepare helpful marks
    helpful_marks = HelpfulMark.for_user_content(current_user, "Review", @reviews.ids)

    # render response
    render json: {
        reviews: json_format(@reviews),
        helpful_marks: helpful_marks,
        max_entries: count,
        entries_per_page: Review.per_page
    }
  end

  # PATCH/PUT /reviews/1
  def update
    builder = ReviewBuilder.update(params[:id], current_user, contribution_update_params)
    authorize! :update, builder.resource
    if builder.update
      render json: {status: :ok}
    else
      render json: builder.errors, status: :unprocessable_entity
    end
  end

  # POST /reviews
  def create
    builder = ReviewBuilder.new(current_user, contribution_params)
    authorize! :create, builder.resource
    if builder.save
      render json: builder.resource.reload
    else
      render json: builder.errors, status: :unprocessable_entity
    end
  end

  # NOT CORRECTABLE
  def corrections
    render json: {error: "Reviews are not correctable."}, status: 404
  end

  # NOT HISTORICAL
  def history
    render json: {error: "Reviews don't have history."}, status: 404
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_review
      @contribution = Review.find(params[:id])
    end

    # Params we allow filtering on
    def filtering_params
      params[:filters].slice(:adult, :hidden, :approved, :game, :search, :overall_rating, :helpfulness, :reputation, :helpful_count, :not_helpful_count, :ratings_count, :submitted, :edited);
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
