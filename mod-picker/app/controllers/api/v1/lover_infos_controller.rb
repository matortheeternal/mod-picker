class Api::V1::LoverInfosController < Api::ApiController
  before_action :set_lover_info, only: [:show]

  # GET /lover_infos/1
  def show
    @lover_info.rescrape
    render json: @lover_info
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_lover_info
      @lover_info = LoverInfo.prepare_for_mod(params[:id])
    end
end
