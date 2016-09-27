class WorkshopInfosController < ApplicationController
  before_action :set_workshop_info, only: [:show, :destroy]

  # GET /workshop_infos/1
  # GET /workshop_infos/1.json
  def show
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
      authorize! :create, Mod
      begin
        @workshop_info = WorkshopInfo.find(params[:id])
        @workshop_info.rescrape
      rescue
        @workshop_info = WorkshopInfo.new(id: params[:id])
        @workshop_info.scrape
        @workshop_info.save
      end
    end
end
