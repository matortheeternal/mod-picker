class HelpPagesController < ApplicationController
  before_action :authorize, only: [:create, :update, :destroy]
  layout "help"

  def index
    @games = Game.all
    @categories = HelpPage.categories
    render "help_pages/index"
  end

  def show
    @help_page = HelpPage.find(params[:id])
    # initial, unoptimized implementation of related pages
    # @related_pages = HelpPage.where.not(id: params[:id])
    #                          .partition { |game| game.game_id == @help_page.game_id}.flatten
    #                          .limit(5)

    render "help_pages/show" 
  end

  def game
    game = Game.find_by_display_name(params[:game])
    @page_title = game.long_name
    
    @help_pages = HelpPage.where(game_id: game.id)

    render "help_pages/game"
  end

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
end
