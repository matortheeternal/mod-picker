class LoadOrderNotesController < HelpfulableController
  before_action :set_load_order_note, only: [:show, :update, :destroy]

  # GET /load_order_notes
  # GET /load_order_notes.json
  def index
    load_order_notes = LoadOrderNote.filter(filtering_params)

    respond_to do |format|
      format.html
      format.json { render :json => load_order_notes}
    end
  end

  # GET /load_order_notes/1
  # GET /load_order_notes/1.json
  def show
    respond_to do |format|
      format.html
      format.json { render :json => load_order_note}
    end
  end

  # POST /load_order_notes
  # POST /load_order_notes.json
  def create
    load_order_note = LoadOrderNote.new(load_order_note_params)

    respond_to do |format|
      if load_order_note.save
        format.json { render :show, status: :created, location: load_order_note }
      else
        format.json { render json: load_order_note.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /load_order_notes/1
  # PATCH/PUT /load_order_notes/1.json
  def update
    respond_to do |format|
      if load_order_note.update(load_order_note_params)
        format.json { render :show, status: :ok, location: load_order_note }
      else
        format.json { render json: load_order_note.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /load_order_notes/1
  # DELETE /load_order_notes/1.json
  def destroy
    load_order_note.destroy
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_load_order_note
      load_order_note = LoadOrderNote.find(params[:id])
    end

    # Params we allow filtering on
    def filtering_params
      params.slice(:by, :mod, :mv);
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def load_order_note_params
      params.require(:load_order_note).permit(:load_first, :load_second, :text_body)
    end
end
