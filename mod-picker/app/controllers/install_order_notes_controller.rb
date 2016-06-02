class InstallOrderNotesController < ContributionsController
  before_action :set_install_order_note, only: [:show, :update, :approve, :hide, :destroy]

  # GET /install_order_notes
  def index
    @install_order_notes = InstallOrderNote.filter(filtering_params)

    render :json => @install_order_notes
  end

  # POST /install_order_notes
  def create
    @install_order_note = InstallOrderNote.new(contribution_params)
    @install_order_note.submitted_by = current_user.id
    authorize! :create, @install_order_note

    if @install_order_note.save
      render json: {status: :ok}
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
      params.slice(:by, :mod);
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def contribution_params
      params.require(:install_order_note).permit(:game_id, :first_mod_id, :second_mod_id, :text_body, :edit_summary)
    end
end
