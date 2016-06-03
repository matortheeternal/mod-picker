class ModListsController < ApplicationController
  before_action :set_mod_list, only: [:show, :update, :destroy]
  before_action :set_active_mod_list, only: [:active]

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
