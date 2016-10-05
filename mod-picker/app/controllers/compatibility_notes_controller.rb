class CompatibilityNotesController < ContributionsController
  before_action :set_compatibility_note, only: [:show, :update, :destroy, :corrections, :history, :approve, :hide]

  # GET /compatibility_notes
  def index
    # prepare compatibility notes
    @compatibility_notes = CompatibilityNote.preload(:editor, :editors).includes(:submitter => :reputation).references(:submitter => :reputation).accessible_by(current_ability).filter(filtering_params).sort(params[:sort]).paginate(:page => params[:page])
    count = CompatibilityNote.includes(:submitter => :reputation).references(:submitter => :reputation).accessible_by(current_ability).filter(filtering_params).count

    # prepare helpful marks
    helpful_marks = HelpfulMark.submitter(current_user.id).helpfulables("CompatibilityNote", @compatibility_notes.ids)

    # render response
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
      params[:filters].slice(:adult, :game, :search, :status, :submitter, :editor, :helpfulness, :reputation, :helpful_count, :not_helpful_count, :standing, :corrections_count, :history_entries_count, :submitted, :edited);
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
