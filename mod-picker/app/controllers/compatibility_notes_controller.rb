class CompatibilityNotesController < ContributionsController
  before_action :set_compatibility_note, only: [:show, :update, :destroy, :approve, :hide]

  # GET /compatibility_notes
  # GET /compatibility_notes.json
  def index
    @compatibility_notes = CompatibilityNote.filter(filtering_params)

    render :json => @compatibility_notes
  end

  # GET /compatibility_notes/1
  # GET /compatibility_notes/1.json
  def show
    render :json => @compatibility_note
  end

  # POST /compatibility_notes
  # POST /compatibility_notes.json
  def create
    @compatibility_note = CompatibilityNote.new(compatibility_note_params)

    if @compatibility_note.save
      render json: {status: :ok}
    else
      render json: @compatibility_note.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /compatibility_notes/1
  # PATCH/PUT /compatibility_notes/1.json
  def update
    if @compatibility_note.update(compatibility_note_params)
      render json: {status: :ok}
    else
      render json: @compatibility_note.errors, status: :unprocessable_entity
    end
  end

  # DELETE /compatibility_notes/1
  # DELETE /compatibility_notes/1.json
  def destroy
    if @compatibility_note.destroy
      render json: {status: :ok}
    else
      render json: @compatibility_note.errors, status: :unprocessable_entity
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_compatibility_note
      @compatibility_note = CompatibilityNote.find(params[:id])
    end

    # Params we allow filtering on
    def filtering_params
      params.slice(:by, :mod, :mv);
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def compatibility_note_params
      params.require(:compatibility_note).permit(:submitted_by, :mod_mode, :compatibility_patch, :compatibility_status)
    end
end
