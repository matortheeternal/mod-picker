class ModListsController < ApplicationController
  before_action :set_mod_list, only: [:show, :update, :destroy, :tools, :plugins, :configs]
  before_action :set_active_mod_list, only: [:active, :mods]

  # GET /mod_lists
  # GET /mod_lists.json
  def index
    @mod_lists = ModList.all

    render :json => @mod_lists
  end

  # GET /mod_lists/1
  # GET /mod_lists/1.json
  def show
    authorize! :read, @mod_list
    render :json => @mod_list
  end

  # GET /mod_lists/active
  def active
    if @mod_list
      render :json => @mod_list
    else
      render status: 404
    end
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
  # POST /mod_lists.json
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
  # PATCH/PUT /mod_lists/1.json
  def update
    authorize! :update, @mod_list
    if @mod_list.update(mod_list_params)
      render json: {status: :ok}
    else
      render json: @mod_list.errors, status: :unprocessable_entity
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
  # DELETE /mod_lists/1.json
  def destroy
    authorize! :destroy, @mod_list
    if @mod_list.destroy
      render json: {status: :ok}
    else
      render json: @mod_list.errors, status: :unprocessable_entity
    end
  end

  # GET /mod_lists/1/tools
  # Get a list of the mods that have utility: true and
  # belong to the specified mod_list
  def tools
    if @mod_list
      # Get all the mod_list_mod records associatd with @mod_list
      # join on the "mod" association on the ModListMod (mod_list_mod.rb) model
      mod_list_mods = @mod_list.mod_list_mods.joins(:mod).where(:mods => {is_utility: true})

      # filter to only include mods who's is_utility is true'
      json_output = mod_list_mods.as_json({:only => [:index, :active], :include => {:mod => {:only => [:id, :name, :is_utility]}}})
      render :json => json_output
    else
      render status: 404
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
