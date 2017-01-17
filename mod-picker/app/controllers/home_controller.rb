class HomeController < ApplicationController
  before_action :authorize, only: [:fallout4]

  def skyrim
    # set instance variables
    @games = Game.all
    @current_game = Game.find_by(display_name: "Skyrim")
    if current_user.present?
      @current_theme = current_user.settings.theme
    else
      @current_theme = 'High Hrothgar'
    end

    # render layout
    render 'angular/index', layout: "application"
  end

  def skyrimse
    # set instance variables
    @games = Game.all
    @current_game = Game.find_by(display_name: "Skyrim SE")
    if current_user.present?
      @current_theme = current_user.settings.theme
    else
      @current_theme = 'High Hrothgar'
    end

    # render layout
    render 'angular/index', layout: "application"
  end

  def fallout4
    # set instance variables
    @games = Game.all
    @current_game = Game.find_by(display_name: "Fallout 4")
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
    articles = Article.accessible_by(current_ability).game(params[:game]).order(submitted: :DESC).limit(4)

    # get recent contributions
    mod_lists = ModList.accessible_by(current_ability).visible.game(params[:game]).where(status: 2).includes(submitter: :reputation).order(completed: :DESC).limit(10)
    mods = Mod.accessible_by(current_ability).visible.adult(0 => true, 1 => false).game(params[:game]).order(submitted: :DESC).limit(10)
    reviews = Review.accessible_by(current_ability).visible.game(params[:game]).includes(:review_ratings, :mod, submitter: :reputation).order(submitted: :DESC).limit(4)
    corrections = Correction.accessible_by(current_ability).visible.game(params[:game]).includes(submitter: :reputation).order(submitted: :DESC).limit(4)
    compatibility_notes = CompatibilityNote.accessible_by(current_ability).visible.game(params[:game]).includes(:first_mod, :second_mod, submitter: :reputation).order(submitted: :DESC).limit(4)
    install_order_notes = InstallOrderNote.accessible_by(current_ability).accessible_by(current_ability).visible.game(params[:game]).includes(:first_mod, :second_mod, submitter: :reputation).order(submitted: :DESC).limit(4)
    load_order_notes = LoadOrderNote.accessible_by(current_ability).visible.game(params[:game]).includes(:first_plugin, :second_plugin, submitter: :reputation).order(submitted: :DESC).limit(4)

    # get helpful/agreement marks
    if current_user.present?
      r_helpful_marks = HelpfulMark.submitter(current_user.id).helpfulables("Review", reviews.ids)
      c_helpful_marks = HelpfulMark.submitter(current_user.id).helpfulables("CompatibilityNote", compatibility_notes.ids)
      i_helpful_marks = HelpfulMark.submitter(current_user.id).helpfulables("InstallOrderNote", install_order_notes.ids)
      l_helpful_marks = HelpfulMark.submitter(current_user.id).helpfulables("LoadOrderNote", load_order_notes.ids)
      agreement_marks = AgreementMark.submitter(current_user.id).corrections(corrections.ids)
    end

    render json: {
        articles: articles,
        recent: {
            mod_lists: json_format(mod_lists, :home),
            mods: json_format(mods, :home),
            reviews: json_format(reviews),
            corrections: json_format(corrections),
            compatibility_notes: compatibility_notes,
            install_order_notes: install_order_notes,
            load_order_notes: load_order_notes,
            r_helpful_marks: r_helpful_marks || [],
            c_helpful_marks: c_helpful_marks || [],
            i_helpful_marks: i_helpful_marks || [],
            l_helpful_marks: l_helpful_marks || [],
            agreement_marks: agreement_marks || []
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
