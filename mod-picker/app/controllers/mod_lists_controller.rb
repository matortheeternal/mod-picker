class ModListsController < ApplicationController
  before_action :set_mod_list, only: [:show, :update, :destroy]

  # GET /mod_lists
  # GET /mod_lists.json
  def index
    @mod_lists = ModList.all

    render :json => @mod_lists
  end

  # GET /mod_lists/1
  # GET /mod_lists/1.json
  def show
    render :json => @mod_list
  end

  # POST /mod_lists
  # POST /mod_lists.json
  def create
    @mod_list = ModList.new(mod_list_params)

    if @mod_list.save
      render json: {status: :ok}
    else
      render json: @mod_list.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /mod_lists/1
  # PATCH/PUT /mod_lists/1.json
  def update
    if @mod_list.update(mod_list_params)
      render json: {status: :ok}
    else
      render json: @mod_list.errors, status: :unprocessable_entity
    end
  end

  # POST /mod_lists/1/star
  def create_star
    @mod_list_star = ModListStar.find_or_initialize_by(mod_list_id: params[:id], user_id: current_user.id)
    if @mod_list_star.save
      render json: {status: :ok}
    else
      render json: @mod_list_star.errors, status: :unprocessable_entity
    end
  end

  # DELETE /mod_lists/1/star
  def destroy_star
    @mod_list_star = ModListStar.find_by(mod_list_id: params[:id], user_id: current_user.id)
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

    # Never trust parameters from the scary internet, only allow the white list through.
    def mod_list_params
      params.require(:mod_list).permit(:game_id, :name, :created_by, :is_collection, :is_public, :has_adult_content, :status, :created, :completed, :description)
    end
end
