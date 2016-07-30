class ArticlesController < ApplicationController
  before_action :set_article, only: [:show, :comments, :image, :update, :destroy]

  # GET /articles/1
  def show
    @article = Article.find(params[:id])
    authorize! :read, @article, :message => "You are not allowed to view this article."
    render :json => @article.as_json
  end

  # GET /articles/new
  def new
    authorize! :create, @article
    @article = Article.new
  end

  # POST /articles
  def create
    authorize! :create, @article
    @article = Article.new(article_params)

    if @article.save
      render json: {status: :ok}
    else
      render json: @article.errors, status: :unprocessable_entity
    end
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
    article = Article.find(params[:id])
    authorize! :read, article
    comments = article.comments.accessible_by(current_ability).sort(params[:sort]).paginate(:page => params[:page], :per_page => 10)
    count = article.comments.accessible_by(current_ability).count
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

    # Never trust parameters from the scary internet, only allow the white list through.
    def article_params
      params.require(:article).permit(:title, :submitted_by, :text_body)
    end

    def image_params
      { image_file: params[:image] }
    end
end
