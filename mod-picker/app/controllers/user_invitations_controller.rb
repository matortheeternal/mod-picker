class UserInvitationsController < Devise::InvitationsController
  before_action :authorize_invite, only: [:new_batch, :create_batch, :new, :create, :destroy]

  # GET /users/invitation/batch/new
  def new_batch
    self.resource = resource_class.new
    render :new_batch
  end

  # POST /users/invitation/batch
  def create_batch
    self.resource = resource_class.new
    if batch_invite_resource
      flash[:notice] = "Invitations sent!"
    else
      flash[:error] = "Invitations failed: " + resource_class.failed_emails.to_s
    end

    redirect_to :users_invitation_batch_new
  end

  protected
    def authorize_invite
      authorize! :invite, User
    end

    def batch_invite_params
      params.require(:user).require(:email)
    end

    def batch_invite_resource
      emails = batch_invite_params.split(",").collect(&:strip)
      User.batch_invite!(emails, current_inviter)
    end
end