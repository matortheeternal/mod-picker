class BaseReportsController < ApplicationController
  # TODO: submission logic

  # GET /reports.json
  def index
    @reports = BaseReport.filter(filtering_params)

    render :json => @reports
  end

  # POST /reviews
  # POST /reviews.json
  def create
    @report = BaseReport.new(base_report_params)

    if @report.save
      render json: {status: :ok}
    else
      render json: @report.errors, status: :unprocessable_entity
    end
  end

  # DELETE /reviews/1
  # DELETE /reviews/1.json
  def destroy
    if @report.destroy
      render json: {status: :ok}
    else
      render json: @report.errors, status: :unprocessable_entity
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_base_report
      @report = BaseReport.find(params[:id])
    end

    # Params we allow filtering on
    def filtering_params
      # TODO
      params.slice;
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def base_report_params
      # TODO
      params.require(:base_report).permit
    end
end
