class LoadOrderNotesController < ContributionsController
  before_action :set_load_order_note, only: [:show, :update, :destroy, :corrections, :history, :approve, :hide]

  # GET /load_order_notes
  def index
    @load_order_notes = LoadOrderNote.includes(:editor, :editors, :submitter => :reputation).accessible_by(current_ability).filter(filtering_params).sort(params[:sort]).paginate(:page => params[:page])
    count = LoadOrderNote.accessible_by(current_ability).filter(filtering_params).count

    # get helpful marks
    helpful_marks = HelpfulMark.where(submitted_by: current_user.id, helpfulable_type: "LoadOrderNote", helpfulable_id: @load_order_notes.ids)
    render :json => {
        load_order_notes: @load_order_notes,
        helpful_marks: helpful_marks,
        max_entries: count,
        entries_per_page: LoadOrderNote.per_page
    }
  end

  # POST /load_order_notes
  def create
    @load_order_note = LoadOrderNote.new(contribution_params)
    @load_order_note.submitted_by = current_user.id
    authorize! :create, @load_order_note

    if @load_order_note.save
      render json: @load_order_note.reload
    else
      render json: @load_order_note.errors, status: :unprocessable_entity
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_load_order_note
      @contribution = LoadOrderNote.find(params[:id])
    end

    # Params we allow filtering on
    def filtering_params
      params.slice(:by, :mod);
    end

    # Params allowed during creation
    def contribution_params
      params.require(:load_order_note).permit(:game_id, :first_plugin_id, :second_plugin_id, :text_body, (:moderator_message if current_user.can_moderate?))
    end

    # Params that can be updated
    def contribution_update_params
      # TODO: only allow swapping the first and second plugin ids
      params.require(:load_order_note).permit(:first_plugin_id, :second_plugin_id, :text_body, :edit_summary, (:moderator_message if current_user.can_moderate?))
    end
end
