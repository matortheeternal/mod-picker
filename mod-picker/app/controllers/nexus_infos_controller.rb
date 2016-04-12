class NexusInfosController < ApplicationController
  before_action :set_nexus_info, only: [:show]

  # GET /nexus_infos/1
  # GET /nexus_infos/1.json
  def show
    respond_to do |format|
      format.html
      format.json { render :json => @nexus_info}
    end
  end

  # DELETE /nexus_infos/1
  # DELETE /nexus_infos/1.json
  def destroy
    @nexus_info.destroy
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_nexus_info
      begin
        @nexus_info = NexusInfo.find(params[:id])
        @nexus_info.rescrape
      rescue
        if params.has_key?(:game_id)
          @nexus_info = NexusInfo.create(id: params[:id], game_id: params[:game_id])
          @nexus_info.scrape
        else
          raise "Cannot scrape Nexus Info with no game id."
        end
      end
    end
end
