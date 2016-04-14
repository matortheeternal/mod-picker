class CompatibilityNotesController < HelpfulableController
  before_action :set_compatibility_note, only: [:show, :update, :destroy]

  # GET /compatibility_notes
  # GET /compatibility_notes.json
  def index
    @compatibility_notes = CompatibilityNote.filter(filtering_params)

    respond_to do |format|
      format.html
      format.json { render :json => @compatibility_notes}
    end
  end

  # GET /compatibility_notes/1
  # GET /compatibility_notes/1.json
  def show
    respond_to do |format|
      format.html
      format.json { render :json => @compatibility_note}
    end
  end

  # POST /compatibility_notes
  # POST /compatibility_notes.json
  def create
    @compatibility_note = CompatibilityNote.new(compatibility_note_params)

    respond_to do |format|
      if @compatibility_note.save
        format.json { render :show, status: :created, location: @compatibility_note }
      else
        format.json { render json: @compatibility_note.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /compatibility_notes/1
  # PATCH/PUT /compatibility_notes/1.json
  def update
    respond_to do |format|
      if @compatibility_note.update(compatibility_note_params)
        format.json { render :show, status: :ok, location: @compatibility_note }
      else
        format.json { render json: @compatibility_note.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /compatibility_notes/1
  # DELETE /compatibility_notes/1.json
  def destroy
    @compatibility_note.destroy
    respond_to do |format|
      format.json { head :no_content }
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
