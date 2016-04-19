class ReportsController < ApplicationController
  before_action :set_report, only: [:destroy]

  # GET /reports.json
  def index
    @reports = BaseReport.filter(filtering_params)
    authorize! :manage, @reports

    render :json => @reports
  end

  # DELETE /reports/1.json
  def destroy
    authorize! :destroy, @report
    if @report.destroy
      render json: {status: :ok}
    else
      render json: @report.errors, status: :unprocessable_entity
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_report
      @report = BaseReport.find_by(params[:id])
    end

    # Params we allow filtering on
    def filtering_params
      # TODO
      params.slice;
    end
end
