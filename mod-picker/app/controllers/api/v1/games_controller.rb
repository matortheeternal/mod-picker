class Api::V1::GamesController < Api::ApiController
  # GET /games
  def index
    @games = Game.all
    render json: @games
  end
end
