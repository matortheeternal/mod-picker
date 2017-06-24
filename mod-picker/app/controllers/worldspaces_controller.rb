class WorldspacesController < ApplicationController
  # GET /worldspaces?game=2
  def index
    render json: Rails.cache.fetch("worldspaces/#{params[:game]}", expires_in: 1.year) do
      @worldspaces = Worldspace.game(params[:game]).includes(:plugin, :cells)
      @worldspaces.to_json
    end
  end
end