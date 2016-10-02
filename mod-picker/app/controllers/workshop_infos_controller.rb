class WorkshopInfosController < ApplicationController
  before_action :set_workshop_info, only: [:show, :destroy]

  # GET /workshop_infos/1
  def show
    begin
      @workshop_info.rescrape
      render :json => @workshop_info
    rescue Exception => e
      render :json => {error: e.message}, status: :unprocessable_entity
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_workshop_info
      authorize! :create, Mod
      begin
        @workshop_info = WorkshopInfo.find(params[:id])
      rescue
        @workshop_info = WorkshopInfo.new(id: params[:id])
      end
    end
end
