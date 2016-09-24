class NexusInfosController < ApplicationController
  before_action :set_nexus_info, only: [:show, :destroy]

  # GET /nexus_infos/1
  # GET /nexus_infos/1.json
  def show
    render :json => @nexus_info
  end

  # DELETE /nexus_infos/1
  # DELETE /nexus_infos/1.json
  def destroy
    authorize! :destroy, @nexus_info
    if @nexus_info.destroy
      render json: {status: :ok}
    else
      render json: @nexus_info.errors, status: :unprocessable_entity
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_nexus_info
      authorize! :submit, Mod
      begin
        @nexus_info = NexusInfo.find(params[:id])
        @nexus_info.rescrape
      rescue
        if params.has_key?(:game_id)
          @nexus_info = NexusInfo.new(id: params[:id], game_id: params[:game_id])
          @nexus_info.scrape
          @nexus_info.save
        else
          raise "Cannot scrape Nexus Info with no game id."
        end
      end
    end
end
