class WorkshopInfosController < ApplicationController
  before_action :set_workshop_info, only: [:show, :destroy]

  # GET /workshop_infos/1
  # GET /workshop_infos/1.json
  def show
    authorize! :read, @workshop_info
    render :json => @workshop_info
  end

  # DELETE /workshop_infos/1
  # DELETE /workshop_infos/1.json
  def destroy
    authorize! :destroy, @workshop_info
    if @workshop_info.destroy
      render json: {status: :ok}
    else
      render json: @workshop_info.errors, status: :unprocessable_entity
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
