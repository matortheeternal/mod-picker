class LoverInfosController < ApplicationController
  before_action :set_lover_info, only: [:show, :destroy]

  # GET /lover_infos/1
  # GET /lover_infos/1.json
  def show
    respond_to do |format|
      format.html
      format.json { render :json => @lover_info}
    end
  end

  # DELETE /lover_infos/1
  # DELETE /lover_infos/1.json
  def destroy
    @lover_info.destroy
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_lover_info
      @lover_info = LoverInfo.find(params[:id])
    end
end
