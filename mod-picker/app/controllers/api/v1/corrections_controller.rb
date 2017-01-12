class Api::V1::CorrectionsController < Api::ApiController
  before_action :set_correction, only: [:show, :comments]

  # GET /corrections
  def index
    @corrections = Correction.preload(:editor).eager_load(:submitter => :reputation).accessible_by(current_ability).filter(filtering_params).sort(params[:sort]).paginate(page: params[:page])
    count = Correction.eager_load(:submitter => :reputation).accessible_by(current_ability).filter(filtering_params).count

    render json: {
        corrections: json_format(@corrections),
        max_entries: count,
        entries_per_page: Correction.per_page
    }
  end

  # GET /corrections/1
  def show
    authorize! :read, @correction
    render json: @correction
  end

  # POST/GET /corrections/1/comments
  def comments
    authorize! :read, @correction
    comments = @correction.comments.includes(submitter: :reputation, children: [submitter: :reputation]).accessible_by(current_ability).sort(params[:sort]).paginate(page: params[:page], per_page: 10)
    count = @correction.comments.accessible_by(current_ability).count

    render json: {
        comments: comments,
        max_entries: count,
        entries_per_page: 10
    }
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_correction
      @correction = Correction.find(params[:id])
    end

    # Params we allow filtering on
    def filtering_params
      params[:filters].slice(:adult, :hidden, :approved, :game, :search, :submitter, :editor, :status, :mod_status, :correctable, :reputation, :agree_count, :disagree_count, :comments, :submitted, :edited);
    end
end
