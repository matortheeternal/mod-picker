class UserTitlesController < ApplicationController
  # GET /user_titles
  def index
    render json: UserTitle.all
  end
end
