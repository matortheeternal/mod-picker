class UserInvitationsController < Devise::InvitationsController
  before_action :require_admin, only: [:new, :create, :destroy]

  private

  def require_admin
    unless current_user.admin?
      flash[:error] = "Only admins can invite new users to the beta"
      redirect_to root_path
    end
  end
end