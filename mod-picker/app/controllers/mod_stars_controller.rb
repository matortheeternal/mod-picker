class ModStarsController < ApplicationController
  before_action :set_mod_star, only: [:show, :edit, :update, :destroy]

  # GET /mod_stars
  # GET /mod_stars.json
  def index
    @mod_stars = ModStar.all

    respond_to do |format|
      format.html
      format.json { render :json => @mod_stars}
    end
  end

  # GET /mod_stars/1
  # GET /mod_stars/1.json
  def show
    respond_to do |format|
      format.html
      format.json { render :json => @mod_star}
    end
  end

  # GET /mod_stars/new
  def new
    @mod_star = ModStar.new
  end

  # GET /mod_stars/1/edit
  def edit
  end

  # POST /mod_stars
  # POST /mod_stars.json
  def create
    @mod_star = ModStar.new(mod_star_params)

    respond_to do |format|
      if @mod_star.save
        format.html { redirect_to @mod_star, notice: 'User mod star map was successfully created.' }
        format.json { render :show, status: :created, location: @mod_star }
      else
        format.html { render :new }
        format.json { render json: @mod_star.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /mod_stars/1
  # PATCH/PUT /mod_stars/1.json
  def update
    respond_to do |format|
      if @mod_star.update(mod_star_params)
        format.html { redirect_to @mod_star, notice: 'User mod star map was successfully updated.' }
        format.json { render :show, status: :ok, location: @mod_star }
      else
        format.html { render :edit }
        format.json { render json: @mod_star.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /mod_stars/1
  # DELETE /mod_stars/1.json
  def destroy
    @mod_star.destroy
    respond_to do |format|
      format.html { redirect_to mod_stars_url, notice: 'User mod star map was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_mod_star
      @mod_star = ModStar.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def mod_star_params
      params.require(:mod_star).permit(:mod_id, :user_id)
    end
end
