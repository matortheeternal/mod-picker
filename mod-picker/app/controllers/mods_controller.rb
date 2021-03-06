class ModsController < ApplicationController
  before_action :set_mod, only: [:mod_options, :edit, :edit_analysis, :update, :hide, :approve, :update_tags, :image, :corrections, :reviews, :compatibility_notes, :install_order_notes, :load_order_notes, :related_mod_notes, :analysis, :destroy]

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
      @mods = Mod.find_batch(params[:batch], params[:game])
      render json: @mods
    else
      @mods = Mod.visible.filter(search_params).order("CHAR_LENGTH(name)").limit(10)
      render json: @mods
    end
  end

  # GET /mods/1
  def show
    @mod = Mod.game(params[:game]).includes(:custom_sources, :plugins, {mod_authors: :user}, {tags: :submitter}, {required_mods: :required_mod}, {required_by: :mod}).find(params[:id])
    authorize! :read, @mod, message: "You are not allowed to view this mod."

    # set up boolean variables
    star = false
    in_mod_list = false
    incompatible = false
    if current_user.present?
      star = ModStar.exists?(mod_id: @mod.id, user_id: current_user.id)
      if current_user.active_mod_list(@mod.game_id).present?
        mod_list = current_user.active_mod_list(@mod.game_id)
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

  # GET /mods/1/mod_options
  def mod_options
    respond_with_json(@mod.mod_options, :preview)
  end

  # GET /mods/new
  def new
    authorize! :create, Mod
    render json: {status: :ok}
  end

  # POST /mods
  def create
    authorize! :create, Mod
    authorize! :assign_custom_sources, Mod if params[:mod].has_key?(:custom_sources_attributes)

    builder = ModBuilder.new(current_user, mod_params)
    if builder.save
      builder.resource.update_metrics
      builder.resource.reload
      render json: {status: :ok, id: builder.resource.id}
    else
      render json: builder.errors, status: :unprocessable_entity
    end
  end

  # GET /mods/1/edit
  def edit
    authorize! :update, @mod, message: "You are not allowed to edit this mod."
    respond_with_json(@mod, nil, :mod)
  end

  # PATCH/PUT /mods/1
  def update
    authorize! :update, @mod
    authorize! :hide, @mod, :message => "You are not allowed to hide/unhide this mod." if params[:mod].has_key?(:hidden)
    authorize! :approve, @mod, :message => "You are not allowed to approve/unapprove this mod." if params[:mod].has_key?(:approved)
    authorize! :update_authors, @mod, :message => "You are not allowed to update this mod's authors." if params[:mod].has_key?(:mod_authors_attributes)
    authorize! :change_status, @mod, :message => "You are not allowed to change this mod's status." if params[:mod].has_key?(:status)
    authorize! :update_options, @mod, :message => "You are not allowed to update this mod's advanced options." if options_params.any?
    authorize! :assign_custom_sources, @mod, :message => "You are not allowed to assign custom sources." if params[:mod].has_key?(:custom_sources_attributes)
    authorize! :update_details, @mod, :message => "You are not allowed to update this mod's details." if details_params.any?
    authorize! :update_download_links, @mod, :message => "You are not allowed to update this mod's download links." if download_links.any?

    builder = ModBuilder.new(current_user, mod_update_params)
    if builder.update
      builder.resource.update_metrics
      render json: {status: :ok}
    else
      render json: builder.errors, status: :unprocessable_entity
    end
  end

  # POST /mods/1/hide
  def hide
    authorize! :hide, @mod, :message => "You are not allowed to hide/unhide this mod."
    builder = ModBuilder.new(current_user, hide_params)
    if builder.update
      render json: {status: :ok}
    else
      render json: @mod.errors, status: :unprocessable_entity
    end
  end

  # POST /mods/1/approve
  def approve
    authorize! :approve, @mod, :message => "You are not allowed to approve/unapprove this mod."
    builder = ModBuilder.new(current_user, approve_params)
    if builder.update
      render json: {status: :ok}
    else
      render json: @mod.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /mods/1/tags
  def update_tags
    builder = TagBuilder.new(@mod, current_user, params[:tags])
    if builder.update_tags
      respond_with_json(@mod.tags, :mod_tags, :tags)
    else
      render json: builder.errors, status: :unprocessable_entity
    end
  end

  # POST /mods/1/image
  def image
    unless (@mod.submitted > 5.minutes.ago) && (current_user.id == @mod.submitted_by)
      authorize! :update, @mod
    end

    if @mod.update(image_params)
      render json: {status: :ok}
    else
      render json: @mod.errors, status: :unprocessable_entity
    end
  end

  # POST /mods/1/star
  def create_star
    @mod_star = ModStar.find_or_initialize_by(mod_id: params[:id], user_id: current_user.id)
    authorize! :create, @mod_star
    if @mod_star.save
      render json: {status: :ok}
    else
      render json: @mod_star.errors, status: :unprocessable_entity
    end
  end

  # DELETE /mods/1/star
  def destroy_star
    @mod_star = ModStar.find_by(mod_id: params[:id], user_id: current_user.id)
    authorize! :destroy, @mod_star
    if @mod_star.nil?
      render json: {status: :ok}
    else
      if @mod_star.destroy
        render json: {status: :ok}
      else
        render json: @mod_star.errors, status: :unprocessable_entity
      end
    end
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

  # POST/GET /mods/1/related_mod_notes
  def related_mod_notes
    authorize! :read, @mod

    # prepare related mod notes
    related_mod_notes = @mod.related_mod_notes.preload(:first_mod, :second_mod, :editor).eager_load(:submitter => :reputation).accessible_by(current_ability).sort(params[:sort]).paginate(page: params[:page], per_page: 10)
    count =  @mod.related_mod_notes.eager_load(:submitter => :reputation).accessible_by(current_ability).count

    # prepare helpful marks
    helpful_marks = HelpfulMark.for_user_content(current_user, "RelatedModNote", related_mod_notes.ids)

    # render response
    render json: {
        related_mod_notes: related_mod_notes,
        helpful_marks: helpful_marks,
        max_entries: count,
        entries_per_page: 10
    }
  end

  # GET /mods/1/analysis
  def analysis
    authorize! :read, @mod
    render json: {
        mod_options: json_format(@mod.mod_options, :show),
        plugins: json_format(@mod.plugins, :show)
    }
  end

  # GET /mods/1/edit_analysis
  def edit_analysis
    authorize! :update, @mod
    respond_with_json(@mod.mod_options, :edit)
  end

  # DELETE /mods/1
  def destroy
    authorize! :destroy, @mod
    if @mod.destroy
      render json: {status: :ok}
    else
      render json: @mod.errors, status: :unprocessable_entity
    end
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

    def approve_params
      {
          id: params[:id],
          approved: params[:approved]
      }
    end

    def hide_params
      {
          id: params[:id],
          hidden: params[:hidden]
      }
    end

    # Params we allow filtering on
    def filtering_params
      # construct valid filters array
      valid_filters = [:adult, :hidden, :approved, :include_utilities, :compatibility, :sources, :search, :terms, :game, :released, :updated, :utility, :categories, :tags, :excluded_tags, :tag_groups, :stars, :reviews, :rating, :reputation, :compatibility_notes, :install_order_notes, :load_order_notes,:related_mod_notes, :mod_options, :asset_files, :plugins, :required_mods, :required_by, :tags_count, :mod_lists, :submitted]
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

    # Never trust parameters from the scary internet, only allow the white list through.
    def mod_params
      params.require(:mod).permit(:game_id, :name, :authors, :aliases, :is_utility, :is_mod_manager, :is_extender, :has_adult_content, :primary_category_id, :secondary_category_id, :released, :updated, :nexus_info_id, :lover_info_id, :workshop_info_id, :curate,
         custom_sources_attributes: [:label, :url],
         required_mods_attributes: [:required_id],
         tag_names: [],
         mod_options_attributes: [:name, :display_name, :size, :md5_hash, :default, :is_installer_option,
            asset_paths: [],
            plugin_dumps: [:filename, :is_esm, :used_dummy_plugins, :author, :description, :crc_hash, :record_count, :override_count, :file_size,
               master_plugins: [:filename, :crc_hash],
               plugin_record_groups_attributes: [:sig, :record_count, :override_count],
               plugin_errors_attributes: [:signature, :form_id, :group, :path, :name, :data],
               overrides_attributes: [:fid, :sig]
             ]
         ])
    end

    def mod_update_params
      p = params.require(:mod).permit(:name, :authors, :aliases, :is_utility, :is_mod_manager, :is_extender, :has_adult_content, :status, :show_details_tab, :description, :notice, :notice_type, :support_link, :issues_link, :primary_category_id, :secondary_category_id, :released, :updated, :mark_updated, :nexus_info_id, :lover_info_id, :workshop_info_id, :disallow_contributors, :disable_reviews, :lock_tags, :hidden, :approved, :tag_names,
         required_mods_attributes: [:id, :required_id, :_destroy],
         mod_licenses_attributes: [:id, :license_id, :license_option_id, :target, :credit, :commercial, :redistribution, :modification, :private_use, :include, :text_body, :_destroy],
          mod_authors_attributes: [:id, :role, :user_id, :_destroy],
          custom_sources_attributes: [:id, :label, :url, :_destroy],
         config_files_attributes: [:id, :filename, :install_path, :text_body, :_destroy],
         tag_names: [],
         mod_options_attributes: [:id, :name, :display_name, :download_link, :size, :md5_hash, :default, :is_installer_option, :_destroy,
            asset_paths: [],
            plugin_dumps: [:id, :filename, :is_esm, :used_dummy_plugins, :author, :description, :crc_hash, :record_count, :override_count, :file_size, :_destroy,
                master_plugins: [:filename, :crc_hash],
                plugin_record_groups_attributes: [:sig, :record_count, :override_count],
                plugin_errors_attributes: [:signature, :form_id, :group, :path, :name, :data],
                overrides_attributes: [:fid, :sig]
            ]
         ])
      p[:id] = params[:id]
      p[:tag_names] = [] if p.has_key?(:tag_names) && p[:tag_names].nil?
      p
    end

    def options_params
      params[:mod].slice(:is_utility, :is_mod_manager, :is_extender, :has_adult_content, :disallow_contributors, :disable_reviews, :lock_tags)
    end

    def details_params
      params[:mod].slice(:show_details_tab, :description, :notice, :notice_type, :support_link, :issues_link, :mod_licenses_attributes)
    end

    def download_links
      if params[:mod].has_key?(:mod_options_attributes)
        params[:mod][:mod_options_attributes].map {|m| m[:download_link]}.compact
      else
        []
      end
    end

    def image_params
      {
          images: {
              big: params.require(:big),
              medium: params.require(:medium),
              small: params.require(:small)
          }
      }
    end
end
