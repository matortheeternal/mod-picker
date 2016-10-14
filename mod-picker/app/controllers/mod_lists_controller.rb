class ModListsController < ApplicationController
  before_action :check_sign_in, only: [:create, :set_active, :update, :update_tags, :create_star, :destroy_star]
  before_action :set_mod_list, only: [:show, :hide, :update, :update_tags, :tools, :mods, :plugins, :export_modlist, :export_plugins, :export_links, :config_files, :analysis, :comments]

  # GET /mod_lists
  def index
    @mod_lists = ModList.includes(:submitter).references(:submitter).accessible_by(current_ability).filter(filtering_params).sort(params[:sort]).paginate(page: params[:page])
    count =  ModList.accessible_by(current_ability).filter(filtering_params).count

    render json: {
        mod_lists: @mod_lists,
        max_entries: count,
        entries_per_page: ModList.per_page
    }
  end

  # GET /mod_lists/1
  def show
    authorize! :read, @mod_list, message: "You are not allowed to view this mod list."
    star = current_user.present? && ModListStar.exists?(mod_list_id: @mod_list.id, user_id: current_user.id)
    render json: {
        mod_list: json_format(@mod_list),
        star: star
    }
  end

  # GET /mod_lists/active
  def active
    @mod_list = current_user.present? && current_user.active_mod_list
    if @mod_list
      respond_with_json(@mod_list, :tracking)
    else
      render json: { error: "No active mod list found." }
    end
  end

  # GET /mod_lists/1/tools
  def tools
    authorize! :read, @mod_list

    # prepare primary data
    tools = @mod_list.mod_list_mods.utility(true).preload(:mod_list_mod_options, :mod => { :mod_options => { :plugins => :mod }}).order(:index)
    custom_tools = @mod_list.custom_mods.utility(true)
    groups = @mod_list.mod_list_groups.where(tab: 0).order(:index)
    required_tools = @mod_list.required_tools

    # render response
    render json: {
        tools: tools,
        custom_tools: custom_tools,
        required_tools: required_tools,
        groups: groups
    }
  end

  # GET /mod_lists/:id/mods
  def mods
    authorize! :read, @mod_list

    # prepare primary data
    mods = @mod_list.mod_list_mods.utility(false).preload(:mod_list_mod_options, :mod => { :mod_options => { :plugins => :mod }}).order(:index)
    custom_mods = @mod_list.custom_mods.utility(false)
    groups = @mod_list.mod_list_groups.where(tab: 1).order(:index)
    required_mods = @mod_list.required_mods

    # prepare notes
    compatibility_notes = @mod_list.mod_compatibility_notes.preload(:submitter, :compatibility_mod, :compatibility_plugin, :editor, :editors, :first_mod, :second_mod)
    install_order_notes = @mod_list.install_order_notes.preload(:submitter, :editor, :editors, :first_mod, :second_mod)

    # prepare helpful marks
    c_helpful_marks = HelpfulMark.submitter(current_user.id).helpfulables("CompatibilityNote", compatibility_notes.ids)
    i_helpful_marks = HelpfulMark.submitter(current_user.id).helpfulables("InstallOrderNote", install_order_notes.ids)

    # render response
    render json: {
        mods: mods,
        custom_mods: custom_mods,
        groups: groups,
        required_mods: required_mods,
        compatibility_notes: CompatibilityNote.mod_list_json(compatibility_notes),
        install_order_notes: install_order_notes,
        c_helpful_marks: c_helpful_marks,
        i_helpful_marks: i_helpful_marks
    }
  end

  # GET /mod_lists/:id/plugins
  def plugins
    authorize! :read, @mod_list

    # prepare primary data
    plugins = @mod_list.mod_list_plugins.includes(:plugin, :mod)
    plugins_store = @mod_list.plugins_store.order(:mod_option_id)
    custom_plugins = @mod_list.custom_plugins
    groups = @mod_list.mod_list_groups.where(tab: 2).order(:index)

    # prepare notes
    compatibility_notes = @mod_list.plugin_compatibility_notes.preload(:submitter, :compatibility_mod, :compatibility_plugin, :editor, :editors, :first_mod, :second_mod)
    load_order_notes = @mod_list.load_order_notes.preload(:submitter, :editor, :editors, :first_mod, :second_mod, :first_plugin, :second_plugin)

    # prepare helpful marks
    c_helpful_marks = HelpfulMark.submitter(current_user.id).helpfulables("CompatibilityNote", compatibility_notes.ids)
    l_helpful_marks = HelpfulMark.submitter(current_user.id).helpfulables("LoadOrderNote", load_order_notes.ids)

    # render response
    render json: {
        plugins: plugins,
        plugins_store: plugins_store,
        custom_plugins: custom_plugins,
        groups: groups,
        required_plugins: @mod_list.required_plugins,
        compatibility_notes: CompatibilityNote.mod_list_json(compatibility_notes),
        load_order_notes: load_order_notes,
        c_helpful_marks: c_helpful_marks,
        l_helpful_marks: l_helpful_marks
    }
  end

  # GET /mod_lists/:id/export_modlist
  def export_modlist
    authorize! :read, @mod_list
    force_download("modlist.txt")
    render text: @mod_list.modlist_text
  end

  # GET /mod_lists/:id/export_plugins
  def export_plugins
    authorize! :read, @mod_list
    force_download("plugins.txt")
    render text: @mod_list.plugins_text
  end

  # GET /mod_lists/:id/export_links
  def export_links
    authorize! :read, @mod_list
    force_download("links.txt")
    render text: @mod_list.links_text
  end

  # GET /mod_lists/:id/config
  def config_files
    authorize! :read, @mod_list

    # prepare primary data
    config_files_store = @mod_list.config_files.order(:mod_id)
    config_files = @mod_list.mod_list_config_files.includes(config_file: :mod)
    custom_config_files = @mod_list.custom_config_files

    # render response
    render json: {
        config_files_store: config_files_store,
        config_files: config_files,
        custom_config_files: custom_config_files
    }
  end

  # GET /mod_lists/1/analysis
  def analysis
    authorize! :read, @mod_list

    # prepare primary data
    plugin_ids = @mod_list.mod_list_plugins.official(false).pluck(:plugin_id)
    install_order = @mod_list.mod_list_mods.utility(false).includes(:mod, :mod_list_mod_options)
    load_order = @mod_list.mod_list_plugins.includes(:plugin)
    plugins = Plugin.where(id: plugin_ids).includes(:mod, :dummy_masters, :overrides, :masters => :master_plugin)

    # render response
    render json: {
        load_order: json_format(load_order, :load_order),
        install_order: json_format(install_order, :install_order),
        plugins: json_format(plugins),
        conflicting_assets: @mod_list.conflicting_assets
    }
  end

  # POST/GET /mod_lists/1/comments
  def comments
    authorize! :read, @mod_list

    # prepare primary data
    comments = @mod_list.comments.includes(submitter: :reputation, children: [submitter: :reputation]).accessible_by(current_ability).sort(params[:sort]).paginate(page: params[:page], per_page: 10)
    count = @mod_list.comments.accessible_by(current_ability).count

    # render response
    render json: {
        comments: comments,
        max_entries: count,
        entries_per_page: 10
    }
  end

  # POST /mod_lists
  def create
    @mod_list = ModList.new(mod_list_params)
    @mod_list.submitted_by = current_user.id
    authorize! :create, @mod_list

    if @mod_list.save
      @mod_list.add_official_content
      if params.has_key?(:active) && params[:active]
        @mod_list.set_active
        respond_with_json(@mod_list, :tracking, :mod_list)
      else
        respond_with_json(@mod_list, :base, :mod_list)
      end
    else
      render json: @mod_list.errors, status: :unprocessable_entity
    end
  end

  # POST /mod_lists/active
  def set_active
    @mod_list = nil
    if params.has_key?(:id) && params[:id]
      @mod_list = ModList.find(params[:id])
      authorize! :read, @mod_list
    end

    if current_user.update(active_mod_list_id: params[:id])
      render json: { mod_list: nil } unless @mod_list.present?
      respond_with_json(@mod_list, :tracking, :mod_list)
    else
      render json: current_user.errors, status: :unproccessable_entity
    end
  end

  # POST /mod_lists/1/hide
  def hide
    authorize! :hide, @mod_list
    @mod_list.hidden = params[:hidden]
    if @mod_list.save
      render json: {status: :ok}
    else
      render json: @mod_list.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /mod_lists/1
  def update
    authorize! :update, @mod_list
    authorize! :hide, @mod_list if params[:mod_list].has_key?(:hidden)

    @mod_list.updated_by = current_user.id
    if @mod_list.update(mod_list_params) && @mod_list.update_lazy_counters
      render json: {status: :ok}
    else
      render json: @mod_list.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /mod_lists/1/tags
  def update_tags
    # errors array to return to user
    errors = ActiveModel::Errors.new(self)
    current_user_id = current_user.id

    # perform tag deletions
    existing_mod_list_tags = @mod_list.mod_list_tags
    existing_tags_text = @mod_list.tags.pluck(:text)
    @mod_list.mod_list_tags.each_with_index do |mod_list_tag, index|
      if params[:tags].exclude?(existing_tags_text[index])
        authorize! :destroy, mod_list_tag
        mod_list_tag.destroy
      end
    end

    # update tags
    params[:tags].each do |tag_text|
      if existing_tags_text.exclude?(tag_text)
        # find or create tag
        tag = Tag.where(game_id: params[:game_id], text: tag_text).first
        if tag.nil?
          tag = Tag.new(game_id: params[:game_id], text: tag_text, submitted_by: current_user_id)
          authorize! :create, tag
          if !tag.save
            tag.errors.full_messages.each {|msg| errors[:base] << msg}
            next
          end
        end

        # create mod tag
        mod_list_tag = @mod_list.mod_list_tags.new(tag_id: tag.id, submitted_by: current_user_id)
        authorize! :create, mod_list_tag
        next if mod_list_tag.save
        mod_list_tag.errors.full_messages.each {|msg| errors[:base] << msg}
      end
    end

    if errors.empty?
      render json: {status: :ok, tags: @mod_list.tags}
    else
      render json: {errors: errors, status: :unprocessable_entity, tags: @mod_list.tags}
    end
  end

  # POST /mod_lists/1/star
  def create_star
    @mod_list_star = ModListStar.find_or_initialize_by(mod_list_id: params[:id], user_id: current_user.id)
    authorize! :create, @mod_list_star
    if @mod_list_star.save
      render json: {status: :ok}
    else
      render json: @mod_list_star.errors, status: :unprocessable_entity
    end
  end

  # DELETE /mod_lists/1/star
  def destroy_star
    @mod_list_star = ModListStar.find_by(mod_list_id: params[:id], user_id: current_user.id)
    authorize! :destroy, @mod_list_star
    if @mod_list_star.nil?
      render json: {status: :ok}
    else
      if @mod_list_star.destroy
        render json: {status: :ok}
      else
        render json: @mod_list_star.errors, status: :unprocessable_entity
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_mod_list
      @mod_list = ModList.find(params[:id])
    end

    def force_download(filename)
      response.headers["Content-Disposition"] = "attachment; filename=#{filename}"
    end

    def filtering_params
      params[:filters].slice(:search, :description, :submitter, :status, :kind, :submitted, :updated, :completed, :tools, :mods, :plugins, :config_files, :ignored_notes, :stars, :custom_tools, :custom_mods, :master_plugins, :available_plugins, :custom_plugins, :custom_config_files, :compatibility_notes, :install_order_notes, :load_order_notes, :bsa_files, :asset_files, :records, :override_records, :plugin_errors, :tags, :comments)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def mod_list_params
      params.require(:mod_list).permit(:game_id, :name, :description, :status, :visibility, :is_collection, :disable_comments, :lock_tags, :hidden,
          mod_list_mods_attributes: [:id, :group_id, :mod_id, :index, :_destroy, mod_list_mod_options_attributes: [:id, :mod_option_id, :_destroy]],
          custom_mods_attributes: [:id, :group_id, :is_utility, :index, :name, :description, :_destroy],
          mod_list_plugins_attributes: [:id, :group_id, :plugin_id, :index, :cleaned, :merged, :_destroy],
          custom_plugins_attributes: [:id, :group_id, :index, :cleaned, :merged, :compatibility_note_id, :filename, :description, :_destroy],
          mod_list_groups_attributes: [:id, :index, :tab, :color, :name, :description, :_destroy,
              children: [:id]
          ],
          mod_list_config_files_attributes: [:id, :config_file_id, :text_body, :_destroy],
          custom_config_files_attributes: [:id, :filename, :install_path, :text_body, :_destroy],
          ignored_notes_attributes: [:id, :note_id, :note_type, :_destroy]
      )
    end
end
