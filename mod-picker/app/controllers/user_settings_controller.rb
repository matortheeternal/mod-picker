class UserSettingsController < ApplicationController
  before_action :check_sign_in
  before_action :set_user, only: [:show, :update]
  before_action :set_current_user, only: [:link_account, :avatar]

  # GET /settings/:id
  def show
    authorize! :update, @user
    respond_with_json(@user, :settings, :user)
  end

  # PATCH/PUT /settings/:id
  def update
    authorize! :update, @user
    authorize! :set_custom_title, @user if params[:user].has_key?(:title)
    authorize! :assign_roles, @user if params[:user].has_key?(:role)

    if @user.update(user_params)
      render json: {status: :ok}
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # GET /settings/link_account
  def link_account
    bio = @user.bio

    if bio.verify_account(params[:site], params[:user_path])
      render json: {status: :ok, verified: true, bio: bio}
    else
      render json: {status: :ok, verified: false}
    end
  end

  # POST /settings/avatar
  def avatar
    authorize! :set_avatar, @user

    if @user.update(avatar_params)
      render json: {status: :ok}
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    def set_current_user
      @user = current_user
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:username, :role, :title, :joined, :about_me, :settings_attributes => [:id, :theme, :allow_comments, :show_notifications, :email_notifications, :email_public, :allow_adult_content, :enable_spellcheck, :allow_nexus_mods, :allow_lovers_lab, :allow_steam_workshop])
    end

    def avatar_params
      {image_file: params[:avatar]}
    end
end
