class WorkshopInfosController < ApplicationController
  before_action :set_workshop_info, only: [:show]

  # GET /workshop_infos/1
  def show
    @workshop_info.rescrape
    render json: @workshop_info
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_workshop_info
      authorize! :create, Mod
      @workshop_info = WorkshopInfo.prepare_for_mod(params[:id])
    end
end
