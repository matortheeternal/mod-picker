class UserTitlesController < ApplicationController
  # GET /user_titles
  def index
    render json: static_cache("user_titles") {
      UserTitle.all.to_json
    }
  end
end
