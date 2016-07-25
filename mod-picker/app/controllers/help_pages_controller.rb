class HelpPagesController < ApplicationController
  before_action :authorize, only: [:create, :update, :destroy]
  layout "help"

  # GET /help
  def index
    @games = Game.all
    @categories = HelpPage.categories
    render "help_pages/index"
  end
  # GET /help/1
  def show
    @help_page = HelpPage.find(params[:id])
    # initial, unoptimized implementation of related pages
    # @related_pages = HelpPage.where.not(id: params[:id])
    #                          .partition { |game| game.game_id == @help_page.game_id}.flatten
    #                          .limit(5)

    render "help_pages/show" 
  end

  # GET /help/new
  def new
    @help_page = HelpPage.new
    render "help_pages/new"
  end

  # POST /help/new
  def create
    @help_page = current_user.help_pages.build(help_page_params)
    authorize! :create, @help_page

    if @help_page.save
      redirect_to "/help/#{@help_page.id}"
    else
      render "help_pages/new"
    end
  end

  # GET /help/1/edit
  def edit
    authorize! :update, @help_page
    @help_page = HelpPage.find(params[:id])
    render "help_pages/edit"
  end

  # PATCH/PUT /help/1
  def update
    authorize! :update, @help_page
    @help_page = HelpPage.find(params[:id])
    if @help_page.update(help_page_params)
      redirect_to "/help/#{@help_page.id}"
    else
      render "help_pages/edit"
    end
  end

  # DELETE /help/1
  def destroy
    HelpPage.find(params[:id]).destroy
    redirect_to action: "index"
  end

  # GET /help/game/game.display_name
  def game
    game = Game.find_by_display_name(params[:game])
    @page_title = game.long_name
    
    @help_pages = HelpPage.where(game_id: game.id)

    render "help_pages/game"
  end

  # GET /help/category/HelpPage.category
  def category
    @page_title = params[:category].humanize.capitalize
    @help_pages = HelpPage.where(category: HelpPage.categories[params[:category]]) 

    render "help_pages/game"
  end

  private
    def authorize
      unless current_user.present?
        redirect_to "/users/sign_in"
      end
      unless current_user.admin?
        redirect_to root_url
      end
    end

    def help_page_params
      params.require(:help_page).permit(:name, :text_body, :game_id, :category)
    end
end
