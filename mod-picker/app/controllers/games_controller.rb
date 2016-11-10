class GamesController < ApplicationController
  # GET /games
  def index
    @games = Game.all

    render json: @games
  end
end
