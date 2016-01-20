class ModStarsController < ApplicationController
  before_action :set_user_mod_star_map, only: [:show, :edit, :update, :destroy]

  # GET /mod_stars
  # GET /mod_stars.json
  def index
    @user_mod_star_maps = ModStar.all
  end

  # GET /mod_stars/1
  # GET /mod_stars/1.json
  def show
  end

  # GET /mod_stars/new
  def new
    @user_mod_star_map = ModStar.new
  end

  # GET /mod_stars/1/edit
  def edit
  end

  # POST /mod_stars
  # POST /mod_stars.json
  def create
    @user_mod_star_map = ModStar.new(user_mod_star_map_params)

    respond_to do |format|
      if @user_mod_star_map.save
        format.html { redirect_to @user_mod_star_map, notice: 'User mod star map was successfully created.' }
        format.json { render :show, status: :created, location: @user_mod_star_map }
      else
        format.html { render :new }
        format.json { render json: @user_mod_star_map.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /mod_stars/1
  # PATCH/PUT /mod_stars/1.json
  def update
    respond_to do |format|
      if @user_mod_star_map.update(user_mod_star_map_params)
        format.html { redirect_to @user_mod_star_map, notice: 'User mod star map was successfully updated.' }
        format.json { render :show, status: :ok, location: @user_mod_star_map }
      else
        format.html { render :edit }
        format.json { render json: @user_mod_star_map.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /mod_stars/1
  # DELETE /mod_stars/1.json
  def destroy
    @user_mod_star_map.destroy
    respond_to do |format|
      format.html { redirect_to user_mod_star_maps_url, notice: 'User mod star map was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user_mod_star_map
      @user_mod_star_map = ModStar.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_mod_star_map_params
      params.require(:user_mod_star_map).permit(:mod_id, :user_id)
    end
end
