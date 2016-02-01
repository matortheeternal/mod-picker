class ModListStarsController < ApplicationController
  before_action :set_mod_list_star, only: [:show, :edit, :update, :destroy]

  # GET /mod_list_stars
  # GET /mod_list_stars.json
  def index
    @mod_list_stars = ModListStar.all

    respond_to do |format|
      format.html
      format.json { render :json => @mod_list_stars}
    end
  end

  # GET /mod_list_stars/1
  # GET /mod_list_stars/1.json
  def show
    respond_to do |format|
      format.html
      format.json { render :json => @mod_list_star}
    end
  end

  # GET /mod_list_stars/new
  def new
    @mod_list_star = ModListStar.new
  end

  # GET /mod_list_stars/1/edit
  def edit
  end

  # POST /mod_list_stars
  # POST /mod_list_stars.json
  def create
    @mod_list_star = ModListStar.new(mod_list_star_params)

    respond_to do |format|
      if @mod_list_star.save
        format.html { redirect_to @mod_list_star, notice: 'User mod list star map was successfully created.' }
        format.json { render :show, status: :created, location: @mod_list_star }
      else
        format.html { render :new }
        format.json { render json: @mod_list_star.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /mod_list_stars/1
  # PATCH/PUT /mod_list_stars/1.json
  def update
    respond_to do |format|
      if @mod_list_star.update(mod_list_star_params)
        format.html { redirect_to @mod_list_star, notice: 'User mod list star map was successfully updated.' }
        format.json { render :show, status: :ok, location: @mod_list_star }
      else
        format.html { render :edit }
        format.json { render json: @mod_list_star.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /mod_list_stars/1
  # DELETE /mod_list_stars/1.json
  def destroy
    @mod_list_star.destroy
    respond_to do |format|
      format.html { redirect_to mod_list_stars_url, notice: 'User mod list star map was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_mod_list_star
      @mod_list_star = ModListStar.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def mod_list_star_params
      params.require(:mod_list_star).permit(:mod_list_id, :user_id)
    end
end
