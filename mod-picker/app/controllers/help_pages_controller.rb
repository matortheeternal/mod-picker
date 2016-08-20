class HelpPagesController < ApplicationController
  before_action :set_help_page, only: [:show, :edit]
  before_action :set_help_page_from_id, only: [:comments, :update, :destroy]
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

    # this makes 2 SQL queries to combine ORs.
    # alternative is to use raw SQL or arel.
    @help_pages = HelpPage.search(params[:search]) | HelpPage.game_long_name(params[:search])

    # @help_pages = HelpPage.where("title LIKE ? OR text_body LIKE ? OR category LIKE ?",
    #          "%#{searchParam}%", "%#{searchParam}%", HelpPage.categories[searchParam.parameterize("_").to_sym]) | 
    #   (HelpPage.joins(:game).where("games.long_name LIKE '%#{searchParam}%' "))

    # @help_pages = HelpPage.where(
    #   HelpPage.arel_table[:text_body].matches("%#{searchParam}%")
    #   .or(
    #     HelpPage.joins(
    #       HelpPage.arel_table.join(Game.arel_table).on(
    #       Game.arel_table[:id].eq(HelpPage.arel_table[:game_id])
    #     )[:long_name].matches("%#{searchParam}%"))
    #   ).or(
    #       HelpPage.arel_table[:title].matches("%#{searchParam}%")
    #   )
    # )

    # @help_pages = HelpPage.select(Arel.star).where(
    #   Game.arel_table[:long_name].matches("%#{searchParam}%").or(
    #     HelpPage.arel_table[:title].matches("%#{searchParam}%")
    #   )).joins(
    #   HelpPage.arel_table.join(Game.arel_table).on(
    #     Game.arel_table[:id].eq(HelpPage.arel_table[:game_id])
    #   ).join_sources
    # )


    # @help_pages = HelpPage.where(
    #   HelpPage.arel_table[:title].matches("%#{searchParam}%").or(
    #     HelpPage.select(Arel.star).where(Game.arel_table[:long_name].matches("%#{searchParam}%")).joins(
    #       HelpPage.arel_table.join(Game.arel_table).on(
    #         Game.arel_table[:id].eq(HelpPage.arel_table[:game_id])
    #       ).join_sources
    #     )
    #   )
    # )

    # puts HelpPage.where(
    #   HelpPage.arel_table[:title].matches("%#{searchParam}%").or(
    #     HelpPage.select(Arel.star).where(Game.arel_table[:long_name].matches("%#{searchParam}%")).joins(
    #       HelpPage.arel_table.join(Game.arel_table).on(
    #         Game.arel_table[:id].eq(HelpPage.arel_table[:game_id])
    #       ).join_sources
    #     )
    #   )
    # ).to_sql

    # @help_pages = HelpPage.where([ byHelpPageTextBody, byHelpPageTitle ].map{|s| s.arel.constraints.reduce(:and) }.reduce(:or))\
      # .merge(byGameLongName)
    # @help_pages = HelpPage
    #   .where("title LIKE ? OR text_body LIKE ?",
    #         "%#{searchParam}%", "%#{searchParam}%").order("submitted DESC")

    # @connection.exec_query(
    #   'select help_pages.* from help_pages INNER JOIN games ON games.id = help_pages.game_id WHERE games.long_name LIKE "%Skyrim%"')


    # 'SELECT help_pages.* FROM help_pages WHERE (SELECT help_pages.* FROM help_pages INNER JOIN games ON games.id = help_pages.game_id WHERE games.long_name LIKE "%Skyrim%"') OR (title LIKE "%Skyrim%"') OR (text_body LIKE "%Skyrim%"')

    # @connection.exec_query('select help_pages.* from help_pages INNER JOIN games ON games.id = help_pages.game_id WHERE (games.long_name LIKE "%Skyrim%") OR (help_pages.title LIKE "%Skyrim%") OR (help_pages.text_body LIKE "%Skyrim%")')
    # @help_pages = ActiveRecord::Base.connection.exec_query('SELECT help_pages.* FROM help_pages INNER JOIN games ON games.id = help_pages.game_id WHERE (games.long_name LIKE "%Skyrim%") OR (help_pages.title LIKE "%Skyrim%") OR (help_pages.text_body LIKE "%Skyrim%")')
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
    @help_pages = HelpPage.where(category: HelpPage.categories[params[:category]]).order(submitted: :desc)
    render "help_pages/category"
  end

  # GET /help/game/:game
  def game
    # find_by! used to RecordNotFound error is raised instead of just returning nil
    game = Game.find_by_display_name!(params[:game].humanize)

    @page_title = game.long_name.titleize
    @help_pages = HelpPage.where(game_id: game.id).order(submitted: :asc)

    render "help_pages/game"
  end

  # POST/GET /help/1/comments
  def comments
    authorize! :read, @help_page
    comments = @help_page.comments.accessible_by(current_ability).sort(params[:sort]).paginate(:page => params[:page], :per_page => 10)
    count = @help_page.comments.accessible_by(current_ability).count
    render :json => {
        comments: comments,
        max_entries: count,
        entries_per_page: 10
    }
  end

  # PATCH/PUT /help/1
  def update
    authorize! :update, @help_page
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

  private
    # exception handling for record not found
    def record_not_found(exception)
      @error = exception.message
      render "help_pages/404", status: 404
    end

    # set instance variable via /help/:id via callback to keep things DRY
    def set_help_page
      @help_page = HelpPage.where(title: params[:id].humanize).first
    end

    def set_help_page_from_id
      @help_page = HelpPage.find(params[:id])
    end

    def help_page_params
      params.require(:help_page).permit(:game_id, :category, :title, :text_body)
    end
end
