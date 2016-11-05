class ReportsController < ApplicationController
  before_action :set_base_report, only: [:resolve]

  # POST /reports/index
  def index
    @reports = BaseReport.includes(reports: :submitter).references(reports: :submitter).preload(:reportable).accessible_by(current_ability).filter(filtering_params).sort(params[:sort]).paginate(page: params[:page])
    count =  BaseReport.includes(reports: :submitter).references(reports: :submitter).accessible_by(current_ability).filter(filtering_params).count

    render json: {
        reports: @reports,
        max_entries: count,
        entries_per_page: BaseReport.per_page
    }
  end

  # POST /reports
  def create
    @base_report = BaseReport.where(base_report_params).first_or_initialize
    authorize! :create, @base_report
    @base_report.save!

    @report = Report.where(
      base_report_id: @base_report.id,
      submitted_by: current_user.id,
    ).first_or_initialize
    # convert string param to int
    @report.reason = report_params[:reason].to_i
    @report.note = report_params[:note]
    authorize! :create, @report
    @report.save!

    errors = nil

    @base_report.errors.each do |key|
      errors[key] = @base_report.errors[key]
    end
    @report.errors.each do |key|
      errors[key] = @report.errors[key]
    end

    if errors.nil?
      render json: {status: :ok}
    else
      render json: errors, status: :unprocessable_entity
    end
  end

  # POST /reports/1/resolve
  def resolve
    authorize! :resolve, @report
    @report.resolved = params[:resolved]
    if @report.save
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
      params[:filters].slice(:submitter, :reportable, :reason, :submitted, :reports_count);
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def report_params
      params.require(:report).permit(:note, :reason)
    end

    def base_report_params
      params.require(:base_report).permit(:reportable_id, :reportable_type)
    end

    def submitter_params
      params.require(:submitter).permit(:id)
    end
end
