class LoverInfosController < ApplicationController
  before_action :set_lover_info, only: [:show, :destroy]

  # GET /lover_infos/1
  def show
    @lover_info.rescrape
    render :json => @lover_info
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_lover_info
      authorize! :create, Mod
      @lover_info = LoverInfo.find_or_initialize_by(id: params[:id])
    end
end
