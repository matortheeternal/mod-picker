class HomeController < ApplicationController
  before_action :authorize, only: [:fallout4]

  def skyrim
    # set instance variables
    @games = Game.all
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
    @games = Game.all
    @current_game = Game.find_by(:display_name => "Fallout 4")
    if current_user.present?
      @current_theme = current_user.settings.theme
    else
      @current_theme = 'Workshop'
    end

    # render layout
    render 'angular/index', layout: "application"
  end

  def index
    @articles = Article.order(:created_at => :DESC).limit(5)
    @mod_lists = ModList.where("status = 3 AND hidden = false AND completed NOT NULL").order(:completed => :DESC).limit(10)
    render :json => {
        articles: @articles.as_json,
        recent_stuff: {
            mod_lists: @mod_lists.as_json,
            mods: {},
            comments: {},
            reviews: {},
            corrections: {},
            compatibility_notes: {},
            install_order_notes: {},
            load_order_notes: {},
        }
    }
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
