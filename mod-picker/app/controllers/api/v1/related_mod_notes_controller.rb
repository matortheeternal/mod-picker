class Api::V1::RelatedModNotesController < Api::V1::ContributionsController
  before_action :set_related_mod_note, only: [:show]

  # GET /related_mod_notes
  def index
    # prepare compatibility notes
    @related_mod_notes = RelatedModNote.preload(:editor, :editors, :first_mod, :second_mod).eager_load(submitter: :reputation).accessible_by(current_ability).filter(filtering_params).sort(params[:sort]).paginate(page: params[:page])
    count = RelatedModNote.eager_load(submitter: :reputation).accessible_by(current_ability).filter(filtering_params).count

    # render response
    render json: {
        related_mod_notes: @related_mod_notes,
        max_entries: count,
        entries_per_page: RelatedModNote.per_page
    }
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_related_mod_note
      @contribution = RelatedModNote.find(params[:id])
    end

    # Params we allow filtering on
    def filtering_params
      params[:filters].slice(:adult, :hidden, :approved, :game, :search, :status, :submitter, :editor, :helpfulness, :reputation, :helpful_count, :not_helpful_count, :submitted, :edited);
    end
end
