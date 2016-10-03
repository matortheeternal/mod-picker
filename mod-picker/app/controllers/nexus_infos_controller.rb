class NexusInfosController < ApplicationController
  before_action :set_nexus_info, only: [:show, :destroy]

  # GET /nexus_infos/1
  def show
    @nexus_info.rescrape
    render :json => @nexus_info
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_nexus_info
      authorize! :create, Mod
      raise "cannot scrape Nexus Info with no game id" unless params.has_key?(:game_id)
      @nexus_info = NexusInfo.find_or_initialize_by({
          id: params[:id],
          game_id: params[:game_id]
      })
    end
end
