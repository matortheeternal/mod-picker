class RelatedModNotesController < ContributionsController
  before_action :set_related_mod_note, only: [:show, :update, :destroy, :approve, :hide]

  # GET /related_mod_notes
  def index
    # prepare related mod notes
    @related_mod_notes = RelatedModNote.preload(:editor, :first_mod, :second_mod).eager_load(submitter: :reputation).accessible_by(current_ability).filter(filtering_params).sort(params[:sort]).paginate(page: params[:page])
    count = RelatedModNote.eager_load(submitter: :reputation).accessible_by(current_ability).filter(filtering_params).count

    # prepare helpful marks
    helpful_marks = HelpfulMark.for_user_content(current_user, "RelatedModNote", @related_mod_notes.ids)

    # render response
    render json: {
        related_mod_notes: @related_mod_notes,
        helpful_marks: helpful_marks,
        max_entries: count,
        entries_per_page: RelatedModNote.per_page
    }
  end

  # POST /related_mod_notes
  def create
    @related_mod_note = RelatedModNote.new(contribution_params)
    @related_mod_note.submitted_by = current_user.id
    authorize! :create, @related_mod_note

    if @related_mod_note.save
      render json: @related_mod_note.reload
    else
      render json: @related_mod_note.errors, status: :unprocessable_entity
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_related_mod_note
      @contribution = RelatedModNote.find(params[:id])
    end

    # Params we allow filtering on
    def filtering_params
      params[:filters].slice(:adult, :hidden, :approved, :game, :search, :status, :submitter, :editor, :helpfulness, :reputation, :helpful_count, :not_helpful_count, :standing, :submitted, :edited);
    end

    # Params allowed during creation
    def contribution_params
      params.require(:related_mod_note).permit(:game_id, :status, :first_mod_id, :second_mod_id, :text_body, (:moderator_message if current_user.can_moderate?))
    end

    # Params that can be updated
    def contribution_update_params
      params.require(:related_mod_note).permit(:status, :text_body, :edit_summary, (:moderator_message if current_user.can_moderate?))
    end
end
