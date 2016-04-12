class HomeController < ApplicationController
  before_action :authorize, only: [:fallout4]

  def skyrim
    # set instance variables
    @current_game = Game.find_by(:display_name => "Skyrim")
    if current_user.present?
      @current_theme = current_user.settings.theme
    else
      @current_theme = 'Whiterun'
    end

    # render layout
    render 'angular/index', layout: "application"
  end

  def fallout4
    # set instance variables
    @current_game = Game.find_by(:display_name => "Fallout 4")
    if current_user.present?
      @current_theme = current_user.settings.theme
    else
      @current_theme = 'Workshop'
    end

    # render layout
    render 'angular/index', layout: "application"
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
