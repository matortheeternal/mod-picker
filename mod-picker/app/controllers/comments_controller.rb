class CommentsController < ApplicationController
  before_action :set_comment, only: [:show, :update, :hide, :destroy]

  # GET /comments
  def index
    @comments = Comment.includes(:commentable, submitter: :reputation).accessible_by(current_ability).filter(filtering_params).sort(params[:sort]).paginate(page: params[:page])
    count = Comment.accessible_by(current_ability).filter(filtering_params).count

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

  # POST /comments
  def create
    @comment = Comment.new(comment_params)
    @comment.submitted_by = current_user.id
    authorize! :create, @comment

    if @comment.save
      render json: json_format(@comment.reload, :show)
    else
      render json: @comment.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /comments/1
  def update
    authorize! :update, @comment
    if @comment.update(comment_params)
      render json: {status: :ok}
    else
      render json: @comment.errors, status: :unprocessable_entity
    end
  end

  # POST /comments/1/hide
  def hide
    authorize! :hide, @comment
    @comment.hidden = params[:hidden]
    if @comment.save
      render json: {status: :ok}
    else
      render json: @comment.errors, status: :unprocessable_entity
    end
  end

  # DELETE /comments/1
  def destroy
    authorize! :destroy, @comment
    if @comment.destroy
      render json: {status: :ok}
    else
      render json: @comment.errors, status: :unprocessable_entity
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_comment
      @comment = Comment.find(params[:id])
    end

    # Params we allow filtering on
    def filtering_params
      params[:filters].slice(:search, :submitter, :include_replies, :commentable, :replies, :submitted, :edited)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def comment_params
      params.require(:comment).permit(:commentable_id, :commentable_type, :parent_id, :text_body)
    end
end
