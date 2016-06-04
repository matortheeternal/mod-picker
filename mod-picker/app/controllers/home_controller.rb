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
    mod_lists = ModList.where("game_id = ? AND status = 3 AND hidden = false", params[:game]).includes(:user => :reputation).order(:edited => :DESC).limit(4)
    mods = Mod.game(params[:game]).where("hidden = false").order(:id => :ASC).limit(4)
    reviews = Review.where("game_id = ? AND hidden = false", params[:game]).includes(:mod, :user => :reputation).order(:submitted => :DESC).limit(4)
    corrections = Correction.where("game_id = ? AND hidden = false", params[:game]).includes(:user => :reputation).order(:submitted => :DESC).limit(4)
    compatibility_notes = CompatibilityNote.where("game_id = ? AND hidden = false", params[:game]).includes(:first_mod, :second_mod, :user => :reputation).order(:submitted => :DESC).limit(4)
    install_order_notes = InstallOrderNote.where("game_id = ? AND hidden = false", params[:game]).includes(:first_mod, :second_mod, :user => :reputation).order(:submitted => :DESC).limit(4)
    load_order_notes = LoadOrderNote.where("game_id = ? AND hidden = false", params[:game]).includes(:first_plugin, :second_plugin, :user => :reputation).order(:submitted => :DESC).limit(4)

    render :json => {
        articles: articles.as_json,
        recent: {
            mod_lists: mod_lists.as_json,
            mods: mods.as_json({
                :only => [:id, :name, :authors, :primary_category_id, :secondary_category_id, :mod_stars_count, :status, :reputation, :average_rating, :released, :reviews_count, :mod_lists_count],
                :include => {:author_users => {:only => [:id, :username]}},
                :methods => [:image]
            }),
            reviews: reviews.as_json({
                :only => [:id, :submitted, :edited, :corrections_count, :text_body],
                :include => {
                    :review_ratings => {
                        :except => [:review_id]
                    },
                    :user => {
                        :only => [:id, :username, :role, :title],
                        :include => {
                            :reputation => {:only => [:overall]}
                        },
                        :methods => :avatar
                    },
                    :mod => {
                        :only => [:id, :name]
                    }
                }
            }),
            corrections: corrections.as_json,
            compatibility_notes: compatibility_notes.as_json({
                :only => [:id, :status, :submitted, :edited, :text_body, :corrections_count],
                :include => {
                    :first_mod => {
                        :only => [:id, :name]
                    },
                    :second_mod => {
                        :only => [:id, :name]
                    },
                    :user => {
                        :only => [:id, :username, :role, :title],
                        :include => {
                            :reputation => {:only => [:overall]}
                        },
                        :methods => :avatar
                    }
                },
                :methods => :mods
            }),
            install_order_notes: install_order_notes.as_json({
                :only => [:id, :submitted, :edited, :text_body],
                :include => {
                    :first_mod => {
                        :only => [:id, :name]
                    },
                    :second_mod => {
                        :only => [:id, :name]
                    },
                    :user => {
                        :only => [:id, :username, :role, :title],
                        :include => {
                            :reputation => {:only => [:overall]}
                        },
                        :methods => :avatar
                    }
                },
                :methods => :mods
            }),
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
