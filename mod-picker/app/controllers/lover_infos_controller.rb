class LoverInfosController < ApplicationController
  before_action :set_lover_info, only: [:show, :destroy]

  # GET /lover_infos/1
  def show
    begin
      @lover_info.rescrape
      render :json => @lover_info
    rescue Exception => e
      render :json => {error: e.message}
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_lover_info
      authorize! :create, Mod
      begin
        @lover_info = LoverInfo.find(params[:id])
      rescue
        @lover_info = LoverInfo.new(id: params[:id])
      end
    end
end
