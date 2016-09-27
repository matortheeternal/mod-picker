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
    authorize! :destroy, @lover_info
    if @lover_info.destroy
      render json: {status: :ok}
    else
      render json: @lover_info.errors, status: :unprocessable_entity
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_lover_info
      authorize! :submit, Mod
      begin
        @lover_info = LoverInfo.find(params[:id])
        @lover_info.rescrape
      rescue
        @lover_info = LoverInfo.new(id: params[:id])
        @lover_info.scrape
        @lover_info.save
      end
    end
end
