class ModListsController < ApplicationController
  before_action :check_sign_in, only: [:create, :set_active, :update, :import, :update_tags, :create_star, :destroy_star]
  before_action :set_mod_list, only: [:hide, :clone, :add, :update, :import, :update_tags, :tools, :mods, :plugins, :export_modlist, :export_plugins, :export_links, :setup, :config_files, :analysis, :comments]
  before_action :soft_set_mod_list, only: [:set_active]
  before_action :require_mpu_user_agent, only: [:setup]

  # GET /mod_lists
  def index
    @mod_lists = ModList.eager_load(:submitter).accessible_by(current_ability).filter(filtering_params).sort(params[:sort]).paginate(page: params[:page])
    count =  ModList.eager_load(:submitter).accessible_by(current_ability).filter(filtering_params).count

    render json: {
        mod_lists: @mod_lists,
        max_entries: count,
        entries_per_page: ModList.per_page
    }
  end

  # GET /mod_lists/1
  def show
    @mod_list = ModList.game(params[:game]).find(params[:id])
    authorize! :read, @mod_list, message: "You are not allowed to view this mod list."
    star = current_user.present? && ModListStar.exists?(mod_list_id: @mod_list.id, user_id: current_user.id)
    render json: {
        mod_list: json_format(@mod_list),
        star: star
    }
  end

  # GET /mod_lists/active
  def active
    @mod_list = current_user && current_user.active_mod_list(params[:game])
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
    required_tools = @mod_list.required_tools.order(:required_id)

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
    required_mods = @mod_list.required_mods.order(:required_id)

    # prepare notes
    compatibility_notes = @mod_list.mod_compatibility_notes.preload(:compatibility_mod, :editor, :editors, :first_mod, :second_mod, :submitter => :reputation)
    install_order_notes = @mod_list.install_order_notes.preload(:editor, :editors, :first_mod, :second_mod, :submitter => :reputation)

    # prepare helpful marks
    c_helpful_marks = HelpfulMark.for_user_content(current_user, "CompatibilityNote", compatibility_notes.map(&:id))
    i_helpful_marks = HelpfulMark.for_user_content(current_user, "InstallOrderNote", install_order_notes.map(&:id))

    # render response
    render json: {
        mods: mods,
        custom_mods: custom_mods,
        groups: groups,
        required_mods: required_mods,
        compatibility_notes: json_format(compatibility_notes, :mod_list),
        install_order_notes: install_order_notes,
        c_helpful_marks: c_helpful_marks,
        i_helpful_marks: i_helpful_marks
    }
  end

  # GET /mod_lists/:id/plugins
  def plugins
    authorize! :read, @mod_list

    # prepare primary data
    plugins = @mod_list.mod_list_plugins.preload(:plugin, :mod)
    plugins_store = @mod_list.plugins_store.order(:mod_option_id).preload(:mod)
    install_order = @mod_list.mod_list_mods.utility(false)
    custom_plugins = @mod_list.custom_plugins
    groups = @mod_list.mod_list_groups.where(tab: 2).order(:index)
    required_plugins = @mod_list.required_plugins.order(:master_plugin_id).preload(:plugin => :mod, :master_plugin => :mod)

    # prepare notes
    compatibility_notes = @mod_list.plugin_compatibility_notes.preload(:compatibility_mod, :compatibility_plugin, :compatibility_mod_option, :editor, :editors, :first_mod, :second_mod, :submitter => :reputation)
    load_order_notes = @mod_list.load_order_notes.preload(:editor, :editors, :submitter => :reputation)

    # prepare helpful marks
    c_helpful_marks = HelpfulMark.for_user_content(current_user, "CompatibilityNote", compatibility_notes.map(&:id))
    l_helpful_marks = HelpfulMark.for_user_content(current_user, "LoadOrderNote", load_order_notes.map(&:id))
    
    # render response
    render json: {
        plugins: plugins,
        plugins_store: json_format(plugins_store, :store),
        install_order: json_format(install_order, :simple),
        custom_plugins: custom_plugins,
        groups: groups,
        required_plugins: required_plugins,
        compatibility_notes: json_format(compatibility_notes, :mod_list),
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

  # POST /mod_lists/:id/setup
  def setup
    authorize! :read, @mod_list
    authorize! :setup, @mod_list
    decorator = ModListSetupDecorator.new(@mod_list)
    send_data SecureData.full(current_user, decorator.to_json)
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
    render json: dynamic_cache("mod_lists/#{params[:id]}/analysis", @mod_list.updated, 2.hours) {
      ModListAnalysisDecorator.new(@mod_list).to_json
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
      new_mod_list_response(@mod_list)
    else
      render json: @mod_list.errors, status: :unprocessable_entity
    end
  end

  # POST /mod_lists/1/clone
  def clone
    authorize! :read, @mod_list
    @new_mod_list = ModList.new(submitted_by: current_user.id)
    builder = ModListBuilder.new(@mod_list, @new_mod_list)
    builder.clone!

    # make the new mod list active and respond with it
    @new_mod_list.reload
    @new_mod_list.set_active
    respond_with_json(@new_mod_list, :tracking, :mod_list)
  end

  # POST /mod_lists/1/add
  def add
    authorize! :read, @mod_list
    @target_mod_list = current_user.active_mod_list(params[:game])
    builder = ModListBuilder.new(@mod_list, @target_mod_list)
    builder.copy!
    respond_with_json(@target_mod_list, :tracking, :mod_list)
  end

  # POST /mod_lists/active
  def set_active
    ActiveModList.clear(params[:game], current_user)
    if @mod_list.present?
      @active_mod_list = ActiveModList.new(active_mod_list_params)
      if @active_mod_list.save
        respond_with_json(@mod_list, :tracking, :mod_list)
      else
        render json: @active_mod_list.errors, status: :unproccessable_entity
      end
    else
      render json: { mod_list: nil }
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
    authorize! :update, @mod_list, message: "You are not allowed to update this mod list"
    authorize! :hide, @mod_list, message: "You are not allowed to hide this mod list" if params[:mod_list].has_key?(:hidden)
    authorize! :update_authors, @mod_list, message: "You are not allowed to update this mod list's authors." if params[:mod_list].has_key?(:mod_list_authors_attributes)
    authorize! :update_options, @mod_list, message: "You are not allowed to update this mod list's advanced options" if options_params.any?

    @mod_list.updated_by = current_user.id
    if @mod_list.update(mod_list_params) && @mod_list.update_lazy_counters!
      ModList.update_adult(@mod_list.id)
      #@mod_list.compact_plugins
      respond_with_json(@mod_list, :tracking, :mod_list)
    else
      render json: @mod_list.errors, status: :unprocessable_entity
    end
  end

  # POST /mod_lists/1/import
  def import
    authorize! :update, @mod_list

    @mod_list.updated_by = current_user.id
    if @mod_list.import(mod_list_import_params) && @mod_list.update_all_counters!
      render json: {status: :ok}
    else
      render json: @mod_list.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /mod_lists/1/tags
  def update_tags
    builder = TagBuilder.new(@mod_list, current_user, params[:tags])
    if builder.update_tags
      respond_with_json(@mod_list.tags, :mod_list_tags, :tags)
    else
      render json: builder.errors, status: :unprocessable_entity
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

    def soft_set_mod_list
      @mod_list = nil
      if params.has_key?(:id) && params[:id]
        @mod_list = ModList.find(params[:id])
        authorize! :read, @mod_list
      end
    end

    def force_download(filename)
      response.headers["Content-Disposition"] = "attachment; filename=#{filename}"
    end

    def require_mpu_user_agent
      unless /ModPickerUtility\/([0-9\.]+)/.match(request.user_agent)
        raise CanCan::AccessDenied.new("Not authorized!", :setup, ModList)
      end
    end

    def new_mod_list_response(mod_list)
      mod_list.reload
      if params.has_key?(:active) && params[:active]
        mod_list.set_active
        respond_with_json(mod_list, :tracking, :mod_list)
      else
        respond_with_json(mod_list, :base, :mod_list)
      end
    end

    def filtering_params
      params[:filters].slice(:game, :adult, :hidden, :search, :description, :submitter, :status, :kind, :submitted, :updated, :completed, :tools, :mods, :plugins, :config_files, :ignored_notes, :stars, :custom_tools, :custom_mods, :master_plugins, :available_plugins, :custom_plugins, :custom_config_files, :compatibility_notes, :install_order_notes, :load_order_notes, :bsa_files, :asset_files, :records, :override_records, :plugin_errors, :tags, :excluded_tags, :comments)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def mod_list_params
      params.require(:mod_list).permit(:game_id, :name, :authors, :description, :status, :visibility, :is_collection, :disable_comments, :lock_tags, :hidden,
          mod_list_mods_attributes: [:id, :group_id, :mod_id, :index, :description, :_destroy, mod_list_mod_options_attributes: [:id, :mod_option_id, :_destroy]],
          mod_list_authors_attributes: [:id, :user_id, :role, :_destroy],
          custom_mods_attributes: [:id, :group_id, :is_utility, :index, :name, :url, :description, :_destroy],
          mod_list_plugins_attributes: [:id, :group_id, :plugin_id, :index, :cleaned, :merged, :description, :_destroy],
          custom_plugins_attributes: [:id, :group_id, :index, :cleaned, :merged, :compatibility_note_id, :filename, :description, :_destroy],
          mod_list_groups_attributes: [:id, :index, :tab, :color, :name, :description, :_destroy,
              children: [:id]
          ],
          mod_list_config_files_attributes: [:id, :config_file_id, :text_body, :_destroy],
          custom_config_files_attributes: [:id, :filename, :install_path, :text_body, :_destroy],
          ignored_notes_attributes: [:id, :note_id, :note_type, :_destroy],
          mod_list_authors_attributes: [:id, :role, :user_id, :_destroy]
      )
    end

    def options_params
      params[:mod_list].slice(:is_collection, :disable_comments, :lock_tags)
    end

    def mod_list_import_params
      params.permit(mods: [:id, :name, :nexus_info_id], plugins: [:id, :filename])
    end

    def options_params
      params[:mod_list].slice(:status, :visibility, :is_collection, :disable_comments, :lock_tags)
    end

    def active_mod_list_params
      {
          game_id: params[:game],
          user_id: current_user.id,
          mod_list_id: params[:id]
      }
    end
end
