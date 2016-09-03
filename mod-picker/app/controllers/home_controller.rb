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

    # get helpful/agreement marks
    r_helpful_marks = HelpfulMark.submitter(current_user.id).helpfulables("Review", reviews.ids)
    c_helpful_marks = HelpfulMark.submitter(current_user.id).helpfulables("CompatibilityNote", compatibility_notes.ids)
    i_helpful_marks = HelpfulMark.submitter(current_user.id).helpfulables("InstallOrderNote", install_order_notes.ids)
    l_helpful_marks = HelpfulMark.submitter(current_user.id).helpfulables("LoadOrderNote", load_order_notes.ids)
    agreement_marks = AgreementMark.submitter(current_user.id).corrections(corrections.ids)

    render :json => {
        articles: articles,
        recent: {
            mod_lists: ModList.home_json(mod_lists),
            mods: Mod.home_json(mods),
            reviews: Review.index_json(reviews),
            corrections: Correction.index_json(corrections),
            compatibility_notes: compatibility_notes,
            install_order_notes: install_order_notes,
            load_order_notes: load_order_notes,
            r_helpful_marks: r_helpful_marks,
            c_helpful_marks: c_helpful_marks,
            i_helpful_marks: i_helpful_marks,
            l_helpful_marks: l_helpful_marks,
            agreement_marks: agreement_marks
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
