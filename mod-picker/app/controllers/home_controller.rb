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
    # load recent data
    @articles = Article.order(:created_at => :DESC).limit(5)
    @mod_lists = ModList.where("game_id = ? AND status = 3 AND hidden = false", params[:game]).order(:completed => :DESC).limit(10)
    @mods = Mod.where("game_id = ? AND hidden = false", params[:game]).order(:id => :ASC).limit(10)
    @reviews = Review.where("game_id = ? AND hidden = false", params[:game]).order(:submitted => :DESC).limit(10)
    @corrections = IncorrectNote.joins(:correctable).where(:correctable => { :game_id => params[:game], :hidden => false}).order(:submitted => :DESC).limit(10)
    @compatibility_notes = CompatibilityNote.where("game_id = ? AND hidden = false", params[:game]).order(:submitted => :DESC).limit(10)
    @install_order_notes = InstallOrderNote.where("game_id = ? AND hidden = false", params[:game]).order(:submitted => :DESC).limit(10)
    @load_order_notes = LoadOrderNote.where("game_id = ? AND hidden = false", params[:game]).order(:submitted => :DESC).limit(10)

    render :json => {
        articles: @articles.as_json,
        recent: {
            mod_lists: @mod_lists.as_json,
            mods: @mods.as_json,
            reviews: @reviews.as_json,
            corrections: @corrections.as_json,
            compatibility_notes: @compatibility_notes.as_json,
            install_order_notes: @install_order_notes.as_json,
            load_order_notes: @load_order_notes.as_json
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
