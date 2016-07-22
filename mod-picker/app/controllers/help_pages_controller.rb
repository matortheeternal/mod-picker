class HelpPagesController < ApplicationController
  before_action :authorize, only: [:create, :update, :destroy]
  layout "help"

  def index
    @games = Game.all
    # Render home page
    # TODO: rename to render help_pages/index
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
