class UsersController < ApplicationController
  before_action :set_user, only: [:show, :update, :destroy]

  # GET /users
  # GET /users.json
  def index
    @users = User.filter(filtering_params)

    render :json => @users
  end

  # GET /users/1
  # GET /users/1.json
  def show
    authorize! :read, @user
    render :json => @user.show_json
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    authorize! :update, @user
    if @user.update(user_params)
      render json: {status: :ok}
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    authorize! :destroy, @user
    if @user.destroy
      render json: {status: :ok}
    else
      render json: @user.errors, status: :unprocessable_entity
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
