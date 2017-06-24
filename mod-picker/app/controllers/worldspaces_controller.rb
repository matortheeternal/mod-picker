class WorldspacesController < ApplicationController
  # GET /worldspaces?game=2
  def index
    render json: static_cache("worldspaces/#{params[:game]}") {
      @worldspaces = Worldspace.game(params[:game]).includes(:plugin, :cells)
      @worldspaces.to_json
    }
  end
end