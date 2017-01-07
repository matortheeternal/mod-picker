class Api::V1::ReviewsController < Api::V1::ContributionsController
  before_action :set_review, only: [:show, :update, :approve, :hide, :destroy]

  # GET /reviews
  def index
    # prepare reviews
    @reviews = Review.preload(:review_ratings).includes(:mod, {submitter: :reputation}, :editor).references({submitter: :reputation}, :editor).accessible_by(current_ability).filter(filtering_params).sort(params[:sort]).paginate(page: params[:page])
    count = Review.accessible_by(current_ability).filter(filtering_params).count

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
      params[:filters].slice(:adult, :hidden, :approved, :game, :search, :submitter, :editor, :overall_rating, :helpfulness, :reputation, :helpful_count, :not_helpful_count, :ratings_count, :submitted, :edited);
    end
end
