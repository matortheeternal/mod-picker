class HelpPagesController < ApplicationController
  before_action :set_help_page, only: [:show, :edit]
  before_action :set_help_page_from_id, only: [:comments, :sections, :update, :destroy]
  rescue_from ::ActiveRecord::RecordNotFound, with: :record_not_found

  layout "help"

  # GET /help
  def index
    @games = Game.all
    @categories = HelpPage.categories.keys
    render "help_pages/index"
  end

  # GET /help/:title
  def show
    authorize! :read, @help_page
    render "help_pages/show" 
  end

  # GET /help/:title/edit
  def edit
    authorize! :update, @help_page
    render "help_pages/edit"
  end

  # GET /help/search?query=...
  def search
    @page_title = params[:search].humanize.titleize

    # search by title and text_body via help_page scope
    @help_pages = HelpPage.eager_load(:submitter).search(params[:search]).accessible_by(current_ability)

    render "help_pages/search"
  end

  # GET /help/new
  def new
    @help_page = HelpPage.new
    authorize! :create, @help_page
    render "help_pages/new"
  end

  # POST /help/new
  def create
    @help_page = HelpPage.new(help_page_params)
    @help_page.submitted_by = current_user.id
    authorize! :create, @help_page

    if @help_page.save
      redirect_to "/help/#{@help_page.url}"
    else
      render "help_pages/new"
    end
  end

  # GET /help/category/:category
  def category
    unless HelpPage.categories.include? params[:category]
      render "help_pages/404", status: 404
      return
    end

    @page_title = params[:category].humanize.titleize
    @help_pages = HelpPage.where(category: HelpPage.categories[params[:category]]).order(submitted: :desc).accessible_by(current_ability)

    render "help_pages/category"
  end

  # GET /help/game/:game
  def game
    # find_by! used to RecordNotFound error is raised instead of just returning nil
    game = Game.find_by_display_name!(params[:game].humanize)

    @page_title = game.long_name.titleize
    @help_pages = HelpPage.where(game_id: game.id).order(submitted: :asc).accessible_by(current_ability)

    render "help_pages/game"
  end

  # POST/GET /help/1/comments
  def comments
    authorize! :read, @help_page
    comments = @help_page.comments.includes(submitter: :reputation, children: [submitter: :reputation]).accessible_by(current_ability).sort(params[:sort]).paginate(page: params[:page], per_page: 10)
    count = @help_page.comments.accessible_by(current_ability).count
    render json: {
        comments: comments,
        max_entries: count,
        entries_per_page: 10
    }
  end

  # GET /help/1/sections
  def sections
    authorize! :read, @help_page
    sections = @help_page.sections.includes(:children)
    render json: {
        sections: sections,
    }
  end

  # PATCH/PUT /help/1
  def update
    authorize! :update, @help_page
    authorize! :approve, @help_page, :message => "You are not allowed to approve/unapprove this help page." if params[:help_page].has_key?(:approved)
    if @help_page.update(help_page_params)
      redirect_to "/help/#{@help_page.url}"
    else
      render "help_pages/edit"
    end
  end

  # DELETE /help/1
  def destroy
    authorize! :destroy, @help_page

    if @help_page.destroy
      redirect_to action: "index"
    else
      redirect_to "/help/#{@help_page.url}/edit"
    end
  end

  # exception handling for record not found
  def record_not_found
    render "help_pages/404", status: 404
  end

  private
    # set instance variable via /help/:id via callback to keep things DRY
    def set_help_page
      @help_page = HelpPage.find_by(title: params[:id].humanize)
      raise ActiveRecord::RecordNotFound if @help_page.nil?
    end

    def set_help_page_from_id
      @help_page = HelpPage.find(params[:id])
    end

    def help_page_params
      params.require(:help_page).permit(:game_id, :approved, :category, :youtube_id, :title, :text_body, sections_attributes: [:id, :label, :description, :seconds, :_destroy])
    end
end
