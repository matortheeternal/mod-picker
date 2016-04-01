class UserBiosController < ApplicationController
  before_action :set_user_bio, only: [:show, :edit, :update, :destroy]

  # GET /user_bios
  # GET /user_bios.json
  def index
    @user_bios = UserBio.all

    respond_to do |format|
      format.json { render :json => @user_bios}
    end
  end

  # GET /user_bios/1
  # GET /user_bios/1.json
  def show
    respond_to do |format|
      format.json { render :json => @user_bio}
    end
  end

  # GET /user_bios/new
  def new
    @user_bio = UserBio.new
  end

  # GET /user_bios/1/edit
  def edit
  end

  # POST /user_bios
  # POST /user_bios.json
  def create
    @user_bio = UserBio.new(user_bio_params)

    respond_to do |format|
      if @user_bio.save
        format.json { render :show, status: :created, location: @user_bio }
      else
        format.json { render json: @user_bio.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /user_bios/1
  # PATCH/PUT /user_bios/1.json
  def update
    respond_to do |format|
      if @user_bio.update(user_bio_params)
        format.json { render :show, status: :ok, location: @user_bio }
      else
        format.json { render json: @user_bio.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /user_bios/1
  # DELETE /user_bios/1.json
  def destroy
    @user_bio.destroy
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user_bio
      @user_bio = UserBio.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_bio_params
      params.require(:user_bio).permit(:steam_username, :nexus_user_id, :lover_user_path)
    end
end
