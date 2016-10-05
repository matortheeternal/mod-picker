class InstallOrderNotesController < ContributionsController
  before_action :set_install_order_note, only: [:show, :update, :corrections, :history, :approve, :hide, :destroy]

  # GET /install_order_notes
  def index
    # prepare install order notes
    @install_order_notes = InstallOrderNote.preload(:editor, :editors).includes(:submitter => :reputation).references(:submitter => :reputation).accessible_by(current_ability).filter(filtering_params).sort(params[:sort]).paginate(:page => params[:page])
    count = InstallOrderNote.accessible_by(current_ability).filter(filtering_params).count

    # prepare helpful marks
    helpful_marks = HelpfulMark.submitter(current_user.id).helpfulables("InstallOrderNote", @install_order_notes.ids)

    # render response
    render :json => {
        install_order_notes: @install_order_notes,
        helpful_marks: helpful_marks,
        max_entries: count,
        entries_per_page: InstallOrderNote.per_page
    }
  end

  # POST /install_order_notes
  def create
    @install_order_note = InstallOrderNote.new(contribution_params)
    @install_order_note.submitted_by = current_user.id
    authorize! :create, @install_order_note

    if @install_order_note.save
      render json: @install_order_note.reload
    else
      render json: @install_order_note.errors, status: :unprocessable_entity
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_install_order_note
      @contribution = InstallOrderNote.find(params[:id])
    end

    # Params we allow filtering on
    def filtering_params
      params[:filters].slice(:adult, :game, :search, :submitter, :editor, :helpfulness, :reputation, :helpful_count, :not_helpful_count, :standing, :corrections_count, :history_entries_count, :submitted, :edited);
    end

    # Params allowed during creation
    def contribution_params
      params.require(:install_order_note).permit(:game_id, :first_mod_id, :second_mod_id, :text_body, (:moderator_message if current_user.can_moderate?))
    end

    # Params that can be updated
    def contribution_update_params
      # TODO: only allow swapping the first and second mod ids
      params.require(:install_order_note).permit(:first_mod_id, :second_mod_id, :text_body, :edit_summary, (:moderator_message if current_user.can_moderate?))
    end
end
