class Api::V1::CommentsController < Api::ApiController
  before_action :set_comment, only: [:show]

  # GET /comments
  def index
    @comments = Comment.eager_load(:submitter => :reputation).preload(:commentable).accessible_by(current_ability).filter(filtering_params).sort(params[:sort]).paginate(page: params[:page])
    count = Comment.eager_load(:submitter => :reputation).accessible_by(current_ability).filter(filtering_params).count

    render json: {
        comments: json_format(@comments),
        max_entries: count,
        entries_per_page: Comment.per_page
    }
  end

  # GET /comments/1
  def show
    authorize! :read, @comment
    respond_with_json(@comment)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_comment
      @comment = Comment.find(params[:id])
    end

    # Params we allow filtering on
    def filtering_params
      params[:filters].slice(:adult, :hidden, :search, :include_replies, :commentable, :replies, :submitted, :edited)
    end
end
