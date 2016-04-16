class CommentsController < ApplicationController
  before_action :set_comment, only: [:show, :update, :destroy]

  # GET /comments
  # GET /comments.json
  def index
    @comments = Comment.filter(filtering_params)

    render :json => @comments
  end

  # GET /comments/1
  # GET /comments/1.json
  def show
    render :json => @comment
  end

  # POST /comments
  # POST /comments.json
  def create
    @comment = Comment.new(comment_params)

    if @comment.save
      render :show, status: :created, location: @comment
    else
      render json: @comment.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /comments/1
  # PATCH/PUT /comments/1.json
  def update
    if @comment.update(comment_params)
      render :show, status: :ok, location: @comment
    else
      render json: @comment.errors, status: :unprocessable_entity
    end
  end

  # DELETE /comments/1
  # DELETE /comments/1.json
  def destroy
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
      params.slice(:type, :target, :by);
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def comment_params
      params.require(:comment).permit(:parent_comment, :submitted_by, :hidden, :submitted, :edited, :text_body)
    end
end
