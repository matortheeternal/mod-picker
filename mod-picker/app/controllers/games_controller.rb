class GamesController < ApplicationController
  # GET /games
  def index
    render json: static_cache("games") {
      Game.all.to_json
    }
  end
end
