class Api::V1::InstallOrderNotesController < Api::ApiController
  before_action :set_install_order_note, only: [:show, :corrections, :history]

  # GET /install_order_notes
  def index
    # prepare install order notes
    @install_order_notes = InstallOrderNote.preload(:editor, :editors).includes(submitter: :reputation).references(submitter: :reputation).accessible_by(current_ability).filter(filtering_params).sort(params[:sort]).paginate(page: params[:page])
    count = InstallOrderNote.accessible_by(current_ability).filter(filtering_params).count

    # render response
    render json: {
        install_order_notes: @install_order_notes,
        max_entries: count,
        entries_per_page: InstallOrderNote.per_page
    }
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_install_order_note
      @contribution = InstallOrderNote.find(params[:id])
    end

    # Params we allow filtering on
    def filtering_params
      params[:filters].slice(:adult, :hidden, :approved, :game, :search, :submitter, :editor, :helpfulness, :reputation, :helpful_count, :not_helpful_count, :standing, :corrections_count, :history_entries_count, :submitted, :edited);
    end

end
