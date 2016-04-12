class WorkshopInfosController < ApplicationController
  before_action :set_workshop_info, only: [:show, :destroy]

  # GET /workshop_infos/1
  # GET /workshop_infos/1.json
  def show
    respond_to do |format|
      format.json { render :json => @workshop_info}
    end
  end

  # DELETE /workshop_infos/1
  # DELETE /workshop_infos/1.json
  def destroy
    @workshop_info.destroy
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_workshop_info
      @workshop_info = WorkshopInfo.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def workshop_info_params
      params.require(:workshop_info).permit(:mod_id)
    end
end
