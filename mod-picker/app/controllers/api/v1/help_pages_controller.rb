class Api::V1::HelpPagesController < Api::ApiController
  before_action :set_help_page_from_id, only: [:show, :comments]

  # GET /help/1
  def show
    authorize! :read, @help_page
    render "help_pages/show" 
  end

  # GET /help/search?query=...
  def search
    @page_title = params[:search].humanize.titleize

    # search by title and text_body via help_page scope
    @help_pages = HelpPage.search(params[:search])

    render "help_pages/search"
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
    comments = @help_page.comments.includes(submitter: :reputation, children: [submitter: :reputation]).accessible_by(current_ability).sort(params[:sort]).paginate(page: params[:page], per_page: 10)
    count = @help_page.comments.accessible_by(current_ability).count
    render json: {
        comments: comments,
        max_entries: count,
        entries_per_page: 10
    }
  end

  private
    def set_help_page_from_id
      @help_page = HelpPage.find(params[:id])
    end

end
