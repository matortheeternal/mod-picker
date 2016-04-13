class UserSettingsController < ApplicationController
  before_action :set_user_setting, only: [:update]

  # GET /user_settings
  # GET /user_settings.json
  # returns the current user's settings
  def index
    @user_setting = current_user.settings

    respond_to do |format|
      format.json { render :json => @user_setting}
    end
  end

  # PATCH/PUT /user_settings/1
  # PATCH/PUT /user_settings/1.json
  def update
    respond_to do |format|
      if @user_setting.update(user_setting_params)
        format.json { render json: {status: 'ok'} }
      else
        format.json { render json: @user_setting.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user_setting
      @user_setting = UserSetting.find(params[:id])
    end

    # Params we allow filtering on
    def filtering_params
      params.slice(:user);
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_setting_params
      params.require(:user_setting).permit(:id, :show_notifications, :show_tooltips, :email_notifications, :email_public, :allow_adult_content, :allow_nexus_mods, :allow_lovers_lab, :allow_steam_workshop, :timezone, :udate_format, :utime_format, :allow_comments, :theme)
    end
end
