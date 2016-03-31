class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  # GET /users
  # GET /users.json
  def index
    @users = User.filter(filtering_params)

    respond_to do |format|
      format.json { render :json => @users}
    end
  end

  # GET /users/1
  # GET /users/1.json
  def show
    respond_to do |format|
      format.html
      format.json { render :json => @user.as_json(
        { :include => {
            :mods => {
                :only => [:id, :name, :game_id, :mod_stars_count]
            },
            :mod_lists => {
                :only => [:id, :is_collection, :is_public, :status, :mods_count, :created]
            },
            :bio => {
                :except => [:user_id]
            },
            :reputation => {
                :only => [:overall]
            }
          }
        }
      )}
    end
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        format.json { render json: {status: 'created'} }
      else
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.json { render json: {status: 'ok'} }
      else
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.joins(:bio, :reputation).find(params[:id])
    end

    # Params we allow filtering on
    def filtering_params
      params.slice(:search, :joined, :level, :rep, :mods, :cnotes, :inotes, :reviews, :nnotes, :comments, :mod_lists);
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:username, :role, :title, :joined, :active_mod_list_id, :email, :about_me)
    end
end
