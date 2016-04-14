class LoverInfosController < ApplicationController
  before_action :set_lover_info, only: [:show, :destroy]

  # GET /lover_infos/1
  # GET /lover_infos/1.json
  def show
    render :json => @lover_info
  end

  # DELETE /lover_infos/1
  # DELETE /lover_infos/1.json
  def destroy
    if @lover_info.destroy
      render json: {status: :ok}
    else
      render json: @lover_info.errors, status: :unprocessable_entity
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_lover_info
      @lover_info = LoverInfo.find(params[:id])
    end
end
