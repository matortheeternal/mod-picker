class ArticlesController < ApplicationController
  before_action :set_article, only: [:show, :edit, :update, :destroy]

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
        entries_per_page: User.per_page
    }
  end

  # GET /articles/new
  def new
    authorize! :create, @article
    @article = Article.new
  end

  # GET /articles/1/edit
  def edit
    authorize! :update, @article
  end

  # POST /articles
  def create
    authorize! :create, @article
    @article = Article.new(article_params)

    if @article.save
      redirect_to @article, notice: 'Article was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /articles/1
  def update
    authorize! :update, @article
    if @article.update(article_params)
      redirect_to @article, notice: 'Article was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /articles/1
  def destroy
    authorize! :destroy, @article
    @article.destroy
    redirect_to articles_url, notice: 'Article was successfully destroyed.'
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

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_article
      @article = Article.find(params[:id])
    end

    # Params we allow filtering on
    def filtering_params
      params[:filters].slice(:search, :submitter, :submitted)
    end

    # Only allow a trusted parameter "white list" through.
    def article_params
      params.require(:article).permit(:title, :submitted_by, :text_body)
    end
end
