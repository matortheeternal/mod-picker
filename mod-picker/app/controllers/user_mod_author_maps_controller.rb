class UserModAuthorMapsController < ApplicationController
  before_action :set_user_mod_author_map, only: [:show, :edit, :update, :destroy]

  # GET /user_mod_author_maps
  # GET /user_mod_author_maps.json
  def index
    @user_mod_author_maps = UserModAuthorMap.all
  end

  # GET /user_mod_author_maps/1
  # GET /user_mod_author_maps/1.json
  def show
  end

  # GET /user_mod_author_maps/new
  def new
    @user_mod_author_map = UserModAuthorMap.new
  end

  # GET /user_mod_author_maps/1/edit
  def edit
  end

  # POST /user_mod_author_maps
  # POST /user_mod_author_maps.json
  def create
    @user_mod_author_map = UserModAuthorMap.new(user_mod_author_map_params)

    respond_to do |format|
      if @user_mod_author_map.save
        format.html { redirect_to @user_mod_author_map, notice: 'User mod author map was successfully created.' }
        format.json { render :show, status: :created, location: @user_mod_author_map }
      else
        format.html { render :new }
        format.json { render json: @user_mod_author_map.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /user_mod_author_maps/1
  # PATCH/PUT /user_mod_author_maps/1.json
  def update
    respond_to do |format|
      if @user_mod_author_map.update(user_mod_author_map_params)
        format.html { redirect_to @user_mod_author_map, notice: 'User mod author map was successfully updated.' }
        format.json { render :show, status: :ok, location: @user_mod_author_map }
      else
        format.html { render :edit }
        format.json { render json: @user_mod_author_map.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /user_mod_author_maps/1
  # DELETE /user_mod_author_maps/1.json
  def destroy
    @user_mod_author_map.destroy
    respond_to do |format|
      format.html { redirect_to user_mod_author_maps_url, notice: 'User mod author map was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user_mod_author_map
      @user_mod_author_map = UserModAuthorMap.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_mod_author_map_params
      params.require(:user_mod_author_map).permit(:mod_id, :user_id)
    end
end
