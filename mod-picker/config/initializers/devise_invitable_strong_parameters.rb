Devise::InvitationsController.class_eval do
  def update_resource_params
    params.require(resource_name).permit(
      :username,
      :invitation_token,
      :password,
      :password_confirmation
    )
  end
end