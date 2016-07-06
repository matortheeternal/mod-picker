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
    articles = Article.order(:submitted => :DESC).limit(4)

    # we include associated data we know we'll need because it increases the speed of the query
    mod_lists = ModList.where("game_id = ? AND status = 3 AND hidden = false", params[:game]).includes(:submitter => :reputation).order(:edited => :DESC).limit(5)
    mods = Mod.game(params[:game]).where("hidden = false").order(:id => :DESC).limit(5)
    reviews = Review.where("game_id = ? AND hidden = false", params[:game]).includes(:mod, :submitter => :reputation).order(:submitted => :DESC).limit(4)
    corrections = Correction.where("game_id = ? AND hidden = false", params[:game]).includes(:submitter => :reputation).order(:submitted => :DESC).limit(4)
    compatibility_notes = CompatibilityNote.where("game_id = ? AND hidden = false", params[:game]).includes(:first_mod, :second_mod, :submitter => :reputation).order(:submitted => :DESC).limit(4)
    install_order_notes = InstallOrderNote.where("game_id = ? AND hidden = false", params[:game]).includes(:first_mod, :second_mod, :submitter => :reputation).order(:submitted => :DESC).limit(4)
    load_order_notes = LoadOrderNote.where("game_id = ? AND hidden = false", params[:game]).includes(:first_plugin, :second_plugin, :submitter => :reputation).order(:submitted => :DESC).limit(4)

    render :json => {
        articles: articles.as_json,
        recent: {
            mod_lists: mod_lists.as_json,
            mods: mods.as_json({
                :only => [:id, :name, :authors, :released],
                :include => {
                    :primary_category => {:only => [:name]}
                },
                :methods => [:image]
            }),
            reviews: reviews.as_json({
                :include => {
                    :review_ratings => {
                        :except => [:review_id]
                    },
                    :submitter=> {
                        :only => [:id, :username, :role, :title],
                        :include => {
                            :reputation => {:only => [:overall]}
                        },
                        :methods => :avatar
                    },
                    :editor => {
                        :only => [:id, :username, :role]
                    },
                    :mod => {
                        :only => [:id, :name]
                    }
                }
            }),
            corrections: corrections.as_json({
                :include => {
                    :correctable => {
                        :only => [:id, :name],
                        :include => {
                            :submitter => {
                                :only => [:id, :username]
                            }
                        },
                        :methods => :mods
                    },
                    :submitter => {
                        :only => [:id, :username, :role, :title],
                        :include => {
                            :reputation => {:only => [:overall]}
                        },
                        :methods => :avatar
                    }
                }
            }),
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
