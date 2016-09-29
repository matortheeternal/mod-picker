class ArticlesController < ApplicationController
  before_action :set_article, only: [:show, :comments, :image, :edit, :update, :destroy]

  # GET /articles/1
  def show
    @article = Article.find(params[:id])
    authorize! :read, @article, :message => "You are not allowed to view this article."
    render :json => @article.as_json
  end

  # GET /articles/index
  def index
    @articles= Article.accessible_by(current_ability).filter(filtering_params).sort(params[:sort]).paginate(:page => params[:page])
    count =  Article.accessible_by(current_ability).filter(filtering_params).count

    render :json => {
        articles: @articles,
        max_entries: count,
        entries_per_page: Article.per_page
    }
  end

  # GET /articles/new
  def new
    authorize! :create, Article
    render json: { status: :ok }
  end

  # POST /articles
  def create
    @article = Article.new(article_params)
    @article.submitted_by = current_user.id
    authorize! :create, @article

    if @article.save
      render json: {status: :ok, id: @article.id}
    else
      render json: @article.errors, status: :unprocessable_entity
    end
  end

  # GET /articles/1/edit
  def edit
    authorize! :update, @article, :message => "You are not allowed to edit this article."
    render :json => @article
  end

  # PATCH/PUT /articles/1
  def update
    authorize! :update, @article, :message => "You are not allowed to edit this article"
    if @article.update(article_params)
      render json: {status: :ok}
    else
      render json: @article.errors, status: :unprocessable_entity
    end
  end

  # DELETE /articles/1
  def destroy
    authorize! :destroy, @article
    if @article.destroy
      render json: {status: :ok}
    else
      render json: @article.errors, status: :unprocessable_entity
    end
  end

  # GET /articles/1/comments
  def comments
    authorize! :read, @article
    comments = @article.comments.accessible_by(current_ability).sort(params[:sort]).paginate(:page => params[:page], :per_page => 10)
    count = @article.comments.accessible_by(current_ability).count
    render :json => {
        comments: comments,
        max_entries: count,
        entries_per_page: 10
    }
  end

  # POST /articles/1/image
  def image
    authorize! :update, @article

    if @article.update(image_params)
      render json: {status: :ok}
    else
      render json: @article.errors, status: :unprocessable_entity
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_article
      @article = Article.find(params[:id])
    end

    # Params we allow filtering on
    def filtering_params
      params[:filters].slice(:search, :text, :submitter, :submitted)
    end

    # Only allow a trusted parameter "white list" through.
    def article_params
      params.require(:article).permit(:id, :title, :text_body)
    end

    def image_params
      { image_file: params[:image] }
    end
end
