class Api::V1::UserTitlesController < Api::ApiController
  # GET /user_titles
  def index
    render json: UserTitle.all
  end
end
