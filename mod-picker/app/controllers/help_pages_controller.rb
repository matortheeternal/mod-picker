class HelpPagesController < ApplicationController
  before_action :authorize, only: [:create, :update, :destroy]

  def index

    # Render home page
    render "help_pages/show", layout: "help"
  end

  private
    def authorize
      unless current_user.present?
        redirect_to "/users/sign_in"
      end
      unless current_user.admin?
        redirect_to root_url
      end
    end
end
