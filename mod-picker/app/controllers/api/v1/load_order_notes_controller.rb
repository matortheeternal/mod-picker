class Api::V1::LoadOrderNotesController < Api::V1::ContributionsController
  before_action :set_load_order_note, only: [:show, :corrections, :history]

  # GET /load_order_notes
  def index
    # prepare load order notes
    @load_order_notes = LoadOrderNote.preload(:editor, :editors).includes(submitter: :reputation).references(submitter: :reputation).accessible_by(current_ability).filter(filtering_params).sort(params[:sort]).paginate(page: params[:page])
    count = LoadOrderNote.accessible_by(current_ability).filter(filtering_params).count

    # render response
    render json: {
        load_order_notes: @load_order_notes,
        max_entries: count,
        entries_per_page: LoadOrderNote.per_page
    }
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_load_order_note
      @contribution = LoadOrderNote.find(params[:id])
    end

    # Params we allow filtering on
    def filtering_params
      params[:filters].slice(:adult, :hidden, :approved, :game, :search, :submitter, :editor, :plugin_filename, :helpfulness, :reputation, :helpful_count, :not_helpful_count, :standing, :corrections_count, :history_entries_count, :submitted, :edited);
    end

end
