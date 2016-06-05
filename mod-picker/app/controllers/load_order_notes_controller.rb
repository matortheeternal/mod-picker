class LoadOrderNotesController < ContributionsController
  before_action :set_load_order_note, only: [:show, :update, :approve, :hide, :destroy]

  # GET /load_order_notes
  def index
    @load_order_notes = LoadOrderNote.filter(filtering_params)

    render :json => @load_order_notes
  end

  # POST /load_order_notes
  def create
    @load_order_note = LoadOrderNote.new(contribution_params)
    @load_order_note.submitted_by = current_user.id
    authorize! :create, @load_order_note

    if @load_order_note.save
      render json: {status: :ok}
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
      params.require(:load_order_note).permit(:game_id, :first_plugin_id, :second_plugin_id, :text_body, :moderator_message)
    end

    # Params that can be updated
    def contribution_update_params
      params.require(:install_order_note).permit(:text_body, :edit_summary, :moderator_message)
    end
end
