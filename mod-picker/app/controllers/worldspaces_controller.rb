class WorkshopInfosController < ApplicationController
  # GET /worldspaces?game_id=2
  def index
    @worldspaces = Worldspace.game(params[:game]).includes(:plugin, :cells)
    render json: @worldspaces
  end
end