class WorkshopInfosController < ApplicationController
  before_action :set_workshop_info, only: [:show, :destroy]

  # GET /workshop_infos/1
  def show
    @workshop_info.rescrape
    render :json => @workshop_info
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_workshop_info
      authorize! :create, Mod
      @workshop_info = WorkshopInfo.find_or_initialize_by(id: params[:id])
    end
end
