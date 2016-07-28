class ArticlesController < ApplicationController
  before_action :set_article, only: [:show, :edit, :update, :destroy]

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

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_article
      @article = Article.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def article_params
      params.require(:article).permit(:title, :submitted_by, :text_body)
    end
end
