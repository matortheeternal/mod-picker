class WelcomeController < ApplicationController
  def index
    return redirect_to "/skyrim" if current_user.present?
    render layout: "landing"
  end
end
