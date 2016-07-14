class ModListsController < ApplicationController
  before_action :set_mod_list, only: [:show, :update, :update_tags, :destroy, :tools, :plugins, :configs]
  before_action :set_active_mod_list, only: [:active, :mods]

  # GET /mod_lists
  def index
    @mod_lists = ModList.all

    render :json => @mod_lists
  end

  # GET /mod_lists/1
  def show
    authorize! :read, @mod_list
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
    tools = @mod_list.mod_list_mods.joins(:mod).where(:mods => {is_utility: true})
    render :json => tools.as_json({
        :only => [:index, :active],
        :include => {
            :mod => {
                :only => [:id, :name, :aliases, :authors, :released, :updated],
                :methods => :image
            }
        }
    })
  end

  # GET /mod_lists/:id/mods
  # filter to only include mods that belong to the mod_list
  def mods
    if @mod_list
      mod_list_mods = @mod_list.mod_list_mods.joins(:mod)

      json_output = mod_list_mods.as_json(
        {:only => [:index, :active],
          :include => {
            :mod => {
              :only => [:id, :name]
            }
          }
        })
      render :json => json_output
    else
      render status: 404
    end
  end

  # GET /mod_lists/:id/plugins
  # filter to include plugins belonging to an individual mod_list
  def plugins
    if @mod_list
      mod_list_plugins = @mod_list.mod_list_plugins.joins(:plugin)

      # format and return json
      json_output = mod_list_plugins.as_json(
        {:only => [:index, :active],
          :include => {
            :plugin => {
              :only => [:id, :filename]
            }
          }
        })
      render :json => json_output
    else
      render status: 404
    end
  end

  # GET /mod_lists/:id/config
  def configs
    if @mod_list
      mod_list_config_files = @mod_list.mod_list_config_files.joins(:config_file)

      # format and return json
      json_output = mod_list_config_files.as_json(
        {:only => [:text_body],
          :include => {
            :config_file => {
              :only => [:filename, :install_path, :text_body, :mod_lists_count]
            }
          }
        })
      render :json => json_output
    else
      render status: 404
    end
  end

  # POST /mod_lists
  def create
    @mod_list = ModList.new(mod_list_params)
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
    if @mod_list.update(mod_list_params)
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

  # DELETE /mod_lists/1
  def destroy
    authorize! :destroy, @mod_list
    if @mod_list.destroy
      render json: {status: :ok}
    else
      render json: @mod_list.errors, status: :unprocessable_entity
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
      params.require(:mod_list).permit(:game_id, :name, :is_collection, :has_adult_content, :status, :visibility, :created, :completed, :description)
    end
end
