class Api::V1::ModsController < Api::ApiController
  before_action :set_mod, only: [:corrections, :reviews, :compatibility_notes, :install_order_notes, :load_order_notes, :analysis]

  # POST /mods/index
  def index
    @mods = Mod.eager_load(:author_users, :nexus_infos, :lover_infos, :workshop_infos).accessible_by(current_ability).filter(filtering_params).sort(sorting_params).paginate(page: params[:page])
    count =  Mod.eager_load(:author_users, :nexus_infos, :lover_infos, :workshop_infos).accessible_by(current_ability).filter(filtering_params).count

    render json: {
      mods: json_format(@mods),
      max_entries: count,
      entries_per_page: Mod.per_page
    }
  end

  # POST /mods/search
  def search
    if params.has_key?(:batch)
      @mods = Mod.find_batch(params[:batch])
      render json: @mods
    else
      @mods = Mod.visible.filter(search_params).limit(10)
      render json: @mods
    end
  end

  # GET /mods/1
  def show
    @mod = Mod.includes(:custom_sources, :plugins, {mod_authors: :user}, {tags: :submitter}, {required_mods: :required_mod}, {required_by: :mod}).find(params[:id])
    authorize! :read, @mod, message: "You are not allowed to view this mod."

    # set up boolean variables
    star = false
    in_mod_list = false
    incompatible = false
    if current_user.present?
      star = ModStar.exists?(mod_id: @mod.id, user_id: current_user.id)
      if current_user.active_mod_list_id.present?
        mod_list = current_user.active_mod_list
        in_mod_list = mod_list.mod_list_mod_ids.include?(@mod.id)
        incompatible = mod_list.incompatible_mod_ids.include?(@mod.id)
      end
    end

    # render response
    render json: {
        mod: json_format(@mod),
        star: star,
        in_mod_list: in_mod_list,
        incompatible: incompatible
    }
  end

  # POST/GET /mods/1/corrections
  def corrections
    authorize! :read, @mod

    # prepare corrections
    corrections = @mod.corrections.accessible_by(current_ability)

    # prepare agreement marks
    agreement_marks = AgreementMark.for_user_content(current_user, corrections.ids)

    # render response
    render json: {
        corrections: corrections,
        agreement_marks: agreement_marks
    }
  end

  # POST/GET /mods/1/reviews
  def reviews
    authorize! :read, @mod

    # prepare reviews
    reviews = @mod.reviews.preload(:review_ratings).includes(submitter: :reputation).references(submitter: :reputation).accessible_by(current_ability).sort(params[:sort]).paginate(page: params[:page], per_page: 10)
    reviews = reviews.where("submitted_by != ? OR hidden = true", current_user.id) if current_user.present?
    count = @mod.reviews.includes(submitter: :reputation).references(submitter: :reputation).accessible_by(current_ability).count
    review_ids = reviews.ids

    # prepare user review
    user_review = Review.user_review(@mod, current_user)
    review_ids.push(user_review.id) if user_review.present?

    # prepare helpful marks
    helpful_marks = HelpfulMark.for_user_content(current_user, "Review", review_ids)

    # render response
    render json: {
        reviews: reviews,
        helpful_marks: helpful_marks,
        user_review: user_review,
        max_entries: count,
        entries_per_page: 10
    }
  end

  # POST/GET /mods/1/compatibility_notes
  def compatibility_notes
    authorize! :read, @mod

    # prepare compatibility notes
    compatibility_notes = @mod.compatibility_notes.preload(:first_mod, :second_mod, :editor, :editors, :compatibility_mod, :compatibility_plugin, :compatibility_mod_option).eager_load(:submitter => :reputation).accessible_by(current_ability).sort(params[:sort]).paginate(page: params[:page], per_page: 10)
    count =  @mod.compatibility_notes.eager_load(:submitter => :reputation).accessible_by(current_ability).count

    # prepare helpful marks
    helpful_marks = HelpfulMark.for_user_content(current_user, "CompatibilityNote", compatibility_notes.ids)

    # render response
    render json: {
        compatibility_notes: compatibility_notes,
        helpful_marks: helpful_marks,
        max_entries: count,
        entries_per_page: 10
    }
  end

  # POST/GET /mods/1/install_order_notes
  def install_order_notes
    authorize! :read, @mod

    # prepare install order notes
    install_order_notes = @mod.install_order_notes.includes(submitter: :reputation).references(submitter: :reputation).accessible_by(current_ability).sort(params[:sort]).paginate(page: params[:page], per_page: 10)
    count =  @mod.install_order_notes.includes(submitter: :reputation).references(submitter: :reputation).accessible_by(current_ability).count

    # prepare helpful marks
    helpful_marks = HelpfulMark.for_user_content(current_user, "InstallOrderNote", install_order_notes.ids)

    # render response
    render json: {
        install_order_notes: install_order_notes,
        helpful_marks: helpful_marks,
        max_entries: count,
        entries_per_page: 10
    }
  end

  # POST/GET /mods/1/load_order_notes
  def load_order_notes
    authorize! :read, @mod

    # render empty array if mod has no plugins
    unless @mod.plugins_count > 0
      render json: { load_order_notes: [] }
      return
    end

    # prepare load order notes
    load_order_notes = @mod.load_order_notes.includes(submitter: :reputation).references(submitter: :reputation).accessible_by(current_ability).sort(params[:sort]).paginate(page: params[:page], per_page: 10)
    count =  @mod.load_order_notes.includes(submitter: :reputation).references(submitter: :reputation).accessible_by(current_ability).count

    # prepare helpful marks
    helpful_marks = HelpfulMark.for_user_content(current_user, "LoadOrderNote", load_order_notes.ids)

    # render response
    render json: {
        load_order_notes: load_order_notes,
        helpful_marks: helpful_marks,
        max_entries: count,
        entries_per_page: 10
    }
  end

  # POST/GET /mods/1/analysis
  def analysis
    authorize! :read, @mod
    render json: {
        mod_options: json_format(@mod.mod_options, :show),
        plugins: json_format(@mod.plugins, :show)
    }
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_mod
      @mod = Mod.find(params[:id])
    end

    # Params we allow searching on
    def search_params
      unless params[:filters].has_key?(:include_games)
        params[:filters][:include_games] = false;
      end
      params[:filters].slice(:search, :game, :utility, :include_games)
    end

    # Params we allow sorting on
    def sorting_params
      params.fetch(:sort, {}).permit(:column, :direction)
    end

    # Params we allow filtering on
    def filtering_params
      # construct valid filters array
      valid_filters = [:adult, :hidden, :approved, :include_utilities, :compatibility, :sources, :search, :author, :mp_author, :game, :released, :updated, :utility, :categories, :tags, :stars, :reviews, :rating, :reputation, :compatibility_notes, :install_order_notes, :load_order_notes, :asset_files, :plugins, :required_mods, :required_by, :tags_count, :mod_lists, :submitted]
      source_filters = [:views, :author, :posts, :videos, :images, :discussions, :downloads, :favorites, :subscribers, :endorsements, :unique_downloads, :files, :bugs, :articles]
      sources = params[:filters][:sources]

      # filters available for nexus and workshop
      valid_filters.push(:posts, :videos, :images, :discussions) if sources[:nexus] || sources[:workshop] && !sources[:lab]
      # filters available for nexus and lab
      valid_filters.push(:downloads) if sources[:nexus] || sources[:lab] && !sources[:workshop]
      # filters available for lab or workshop
      # TODO: file_size
      valid_filters.push(:favorites) if sources[:lab] || sources[:workshop] && !sources[:nexus]
      # filters available for workshop only
      valid_filters.push(:subscribers) if sources[:workshop] && !sources[:lab] && !sources[:nexus]
      # filters available for nexus only
      valid_filters.push(:endorsements, :unique_downloads, :files, :bugs, :articles) if sources[:nexus] && !sources[:lab] && !sources[:workshop]

      # get hash of permitted filters
      permitted_filters = params[:filters].slice(*valid_filters)

      # pad filters with sources
      permitted_filters.each do |key, value|
        if source_filters.include?(key.to_sym)
          unless permitted_filters[key].is_a?(Hash)
            permitted_filters[key] = { value: permitted_filters[key] }
          end
          permitted_filters[key][:sources] = sources
        end
      end

      permitted_filters
    end
end
