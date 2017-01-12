class Api::V1::CompatibilityNotesController < Api::V1::ContributionsController
  before_action :set_compatibility_note, only: [:show, :corrections, :history]

  # GET /compatibility_notes
  def index
    # prepare compatibility notes
    @compatibility_notes = CompatibilityNote.preload(:editor, :editors, :first_mod, :second_mod, :compatibility_mod, :compatibility_plugin, :compatibility_mod_option).eager_load(submitter: :reputation).accessible_by(current_ability).filter(filtering_params).sort(params[:sort]).paginate(page: params[:page])
    count = CompatibilityNote.eager_load(submitter: :reputation).accessible_by(current_ability).filter(filtering_params).count

    # render response
    render json: {
        compatibility_notes: @compatibility_notes,
        max_entries: count,
        entries_per_page: CompatibilityNote.per_page
    }
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_compatibility_note
      @contribution = CompatibilityNote.find(params[:id])
    end

    # Params we allow filtering on
    def filtering_params
      params[:filters].slice(:adult, :hidden, :approved, :game, :search, :status, :submitter, :editor, :helpfulness, :reputation, :helpful_count, :not_helpful_count, :standing, :corrections_count, :history_entries_count, :submitted, :edited);
    end
end
