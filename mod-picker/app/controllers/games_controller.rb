class GamesController < ApplicationController
  # GET /games
  # GET /games.json
  def index
    @games = Game.all

    render json: @games
  end
end
