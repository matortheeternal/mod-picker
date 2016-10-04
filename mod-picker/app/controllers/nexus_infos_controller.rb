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
      @nexus_info = NexusInfo.prepare_for_mod(params[:id], params[:game_id])
    end
end
