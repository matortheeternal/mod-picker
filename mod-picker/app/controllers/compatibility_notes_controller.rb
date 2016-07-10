class CompatibilityNotesController < ContributionsController
  before_action :set_compatibility_note, only: [:show, :update, :destroy, :corrections, :history, :approve, :hide]

  # GET /compatibility_notes
  def index
    @compatibility_notes = CompatibilityNote.includes(:editor, :editors, :submitter => :reputation).accessible_by(current_ability).filter(filtering_params).sort(params[:sort]).paginate(:page => params[:page])
    count = CompatibilityNote.accessible_by(current_ability).filter(filtering_params).count

    # get helpful marks
    helpful_marks = HelpfulMark.where(submitted_by: current_user.id, helpfulable_type: "CompatibilityNote", helpfulable_id: @compatibility_notes.ids)
    render :json => {
        compatibility_notes: @compatibility_notes,
        helpful_marks: helpful_marks,
        max_entries: count,
        entries_per_page: CompatibilityNote.per_page
    }
  end

  # POST /compatibility_notes
  def create
    @compatibility_note = CompatibilityNote.new(contribution_params)
    @compatibility_note.submitted_by = current_user.id
    authorize! :create, @compatibility_note

    if @compatibility_note.save
      render json: @compatibility_note.reload
    else
      render json: @compatibility_note.errors, status: :unprocessable_entity
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_compatibility_note
      @contribution = CompatibilityNote.find(params[:id])
    end

    # Params we allow filtering on
    def filtering_params
      params.slice(:by, :mod);
    end

    # Params allowed during creation
    def contribution_params
      params.require(:compatibility_note).permit(:game_id, :status, :first_mod_id, :second_mod_id, :text_body, (:moderator_message if current_user.can_moderate?), :compatibility_plugin_id, :compatibility_mod_id)
    end

    # Params that can be updated
    def contribution_update_params
      params.require(:compatibility_note).permit(:status, :text_body, :edit_summary, (:moderator_message if current_user.can_moderate?), :compatibility_plugin_id, :compatibility_mod_id)
    end
end
