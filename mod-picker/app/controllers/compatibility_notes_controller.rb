class CompatibilityNotesController < ContributionsController
  before_action :set_compatibility_note, only: [:show, :update, :destroy, :approve, :hide]

  # GET /compatibility_notes
  def index
    @compatibility_notes = CompatibilityNote.filter(filtering_params)

    render :json => @compatibility_notes
  end

  # POST /compatibility_notes
  def create
    @compatibility_note = CompatibilityNote.new(contribution_params)
    @compatibility_note.submitted_by = current_user.id
    authorize! :create, @compatibility_note

    if @compatibility_note.save
      render json: {status: :ok}
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

    # Never trust parameters from the scary internet, only allow the white list through.
    def contribution_params
      params.require(:compatibility_note).permit(:game_id, :status, :first_mod_id, :second_mod_id, :text_body, :edit_summary, :compatibility_plugin_id, :compatibility_mod_id)
    end
end
