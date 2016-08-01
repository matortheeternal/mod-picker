class ModListsController < ApplicationController
  before_action :set_mod_list, only: [:show, :update, :update_tags, :destroy, :tools, :plugins, :config_files, :comments]
  before_action :set_active_mod_list, only: [:active, :mods]

  # GET /mod_lists
  def index
    @mod_lists = ModList.all

    render :json => @mod_lists
  end

  # GET /mod_lists/1
  def show
    authorize! :read, @mod_list, :message => "You are not allowed to view this mod list."
    star = ModListStar.exists?(:mod_list_id => @mod_list.id, :user_id => current_user.id)
    render :json => {
        mod_list: @mod_list.show_json,
        star: star
    }
  end

  # GET /mod_lists/active
  def active
    if @mod_list
      render :json => @mod_list
    else
      render status: 404
    end
  end

  # GET /mod_lists/1/tools
  def tools
    authorize! :read, @mod_list

    # prepare primary data
    tools = @mod_list.mod_list_mods.utility(true).includes(:mod => :required_mods).order(:index)
    groups = @mod_list.mod_list_groups.where(tab: 0).order(:index)

    # render response
    render :json => {
        tools: tools,
        required_tools: @mod_list.required_tools,
        groups: groups
    }
  end

  # GET /mod_lists/:id/mods
  def mods
    authorize! :read, @mod_list

    # prepare primary data
    mods = @mod_list.mod_list_mods.utility(false).includes(:mod).order(:index)
    groups = @mod_list.mod_list_groups.where(tab: 1).order(:index)

    # prepare notes
    compatibility_notes = @mod_list.mod_compatibility_notes
    install_order_notes = @mod_list.install_order_notes

    # prepare helpful marks
    c_helpful_marks = HelpfulMark.submitter(current_user.id).helpfulable("CompatibilityNote", compatibility_notes.ids)
    i_helpful_marks = HelpfulMark.submitter(current_user.id).helpfulable("InstallOrderNote", install_order_notes.ids)

    # render response
    render :json => {
        mods: mods,
        groups: groups,
        required_mods: @mod_list.required_mods,
        compatibility_notes: compatibility_notes,
        install_order_notes: install_order_notes,
        c_helpful_marks: c_helpful_marks,
        i_helpful_marks: i_helpful_marks
    }
  end

  # GET /mod_lists/:id/plugins
  def plugins
    authorize! :read, @mod_list

    # prepare primary data
    plugins = @mod_list.mod_list_plugins.includes(:plugin)
    plugin_store = @mod_list.plugins
    custom_plugins = @mod_list.custom_plugins
    groups = @mod_list.mod_list_groups.where(tab: 2).order(:index)

    # prepare notes
    compatibility_notes = @mod_list.plugin_compatibility_notes
    load_order_notes = @mod_list.load_order_notes

    # prepare helpful marks
    c_helpful_marks = HelpfulMark.submitter(current_user.id).helpfulable("CompatibilityNote", compatibility_notes.ids)
    l_helpful_marks = HelpfulMark.submitter(current_user.id).helpfulable("LoadOrderNote", load_order_notes.ids)

    # render response
    render :json => {
        plugins: plugins,
        plugin_store: plugin_store,
        custom_plugins: custom_plugins,
        groups: groups,
        required_plugins: @mod_list.required_plugins,
        compatibility_notes: compatibility_notes,
        load_order_notes: load_order_notes,
        c_helpful_marks: c_helpful_marks,
        l_helpful_marks: l_helpful_marks
    }
  end

  # GET /mod_lists/:id/config_files
  def config_files
    authorize! :read, @mod_list

    # prepare primary data
    config_files = @mod_list.mod_list_config_files.joins(:config_file)
    custom_config_files = @mod_list.mod_list_custom_config_files

    # render response
    render :json => {
        config_files: config_files,
        custom_config_files: custom_config_files
    }
  end

  # POST/GET /mod_lists/1/comments
  def comments
    authorize! :read, @mod_list

    # prepare primary data
    comments = @mod_list.comments.accessible_by(current_ability).sort(params[:sort]).paginate(:page => params[:page], :per_page => 10)
    count = @mod_list.comments.accessible_by(current_ability).count

    # render response
    render :json => {
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
      render json: {status: :ok}
    else
      render json: @mod_list.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /mod_lists/1
  def update
    authorize! :update, @mod_list
    authorize! :hide, @mod_list if params[:mod_list].has_key?(:hidden)

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

    def set_active_mod_list
      # TODO: handle user not logged in
      if current_user
        if current_user.active_mod_list_id
          @mod_list = current_user.active_mod_list
        else
          @mod_list = current_user.mod_lists.create(
              submitted_by: current_user.id,
              game_id: params[:game_id] || Game.first.id,
              name: current_user.username + "'s Mod List'"
          )
        end
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def mod_list_params
      params.require(:mod_list).permit(:game_id, :name, :description, :status, :visibility, :is_collection, :disable_comments, :lock_tags, :hidden,
          :mod_list_mods_attributes => [:id, :group_id, :mod_id, :index, :_destroy],
          :custom_mods_attributes => [:id, :group_id, :is_utility, :index, :name, :description, :_destroy],
          :mod_list_plugins_attributes => [:id, :group_id, :plugin_id, :index, :cleaned, :merged, :_destroy],
          :custom_plugins_attributes => [:id, :group_id, :index, :cleaned, :merged, :compatibility_note_id, :filename, :description, :_destroy],
          :mod_list_groups_attributes => [:id, :index, :tab, :color, :name, :description, :_destroy,
              :children => [:id]
          ],
          :mod_list_config_files_attributes => [:id, :config_file_id, :text_body, :_destroy],
          :custom_config_files_attributes => [:id, :filename, :install_path, :text_body, :_destroy],
          :ignored_notes_attributes => [:id, :note_id, :note_type, :_destroy]
      )
    end
end
