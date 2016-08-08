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
    # we first get news articles
    articles = Article.game(params[:game]).order(:submitted => :DESC).limit(4)

    # get recent contributions
    mod_lists = ModList.visible.game(params[:game]).where(:status => 2).includes(:submitter => :reputation).order(:completed => :DESC).limit(5)
    mods = Mod.include_hidden(false).game(params[:game]).order(:id => :DESC).limit(5)
    reviews = Review.visible.game(params[:game]).includes(:review_ratings, :mod, :submitter => :reputation).order(:submitted => :DESC).limit(4)
    corrections = Correction.visible.game(params[:game]).includes(:submitter => :reputation).order(:submitted => :DESC).limit(4)
    compatibility_notes = CompatibilityNote.visible.game(params[:game]).includes(:first_mod, :second_mod, :submitter => :reputation).order(:submitted => :DESC).limit(4)
    install_order_notes = InstallOrderNote.visible.game(params[:game]).includes(:first_mod, :second_mod, :submitter => :reputation).order(:submitted => :DESC).limit(4)
    load_order_notes = LoadOrderNote.visible.game(params[:game]).includes(:first_plugin, :second_plugin, :submitter => :reputation).order(:submitted => :DESC).limit(4)

    render :json => {
        articles: articles.as_json,
        recent: {
            mod_lists: ModList.home_json(mod_lists),
            mods: Mod.home_json(mods),
            reviews: Review.index_json(reviews),
            corrections: Correction.index_json(corrections),
            compatibility_notes: compatibility_notes.as_json,
            install_order_notes: install_order_notes.as_json,
            load_order_notes: load_order_notes.as_json
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
