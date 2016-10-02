class NexusInfosController < ApplicationController
  before_action :set_nexus_info, only: [:show, :destroy]

  # GET /nexus_infos/1
  def show
    begin
      @nexus_info.rescrape
      render :json => @nexus_info
    rescue Exception => e
      render :json => {error: e.message}, status: :unprocessable_entity
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_nexus_info
      authorize! :create, Mod
      begin
        @nexus_info = NexusInfo.find(params[:id])
      rescue
        if params.has_key?(:game_id)
          @nexus_info = NexusInfo.new(id: params[:id], game_id: params[:game_id])
        else
          raise "Cannot scrape Nexus Info with no game id."
        end
      end
    end
end
