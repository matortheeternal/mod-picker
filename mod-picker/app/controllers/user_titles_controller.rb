class UserTitlesController < ApplicationController
  # GET /user_titles
  # GET /user_titles.json
  def index
    @user_titles = UserTitle.filter(filtering_params)

    format.json { render :json => @user_titles}
  end

  private

  # Params we allow filtering on
  def filtering_params
    params.slice(:game);
  end
end
