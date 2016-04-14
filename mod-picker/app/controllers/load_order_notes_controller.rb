class LoadOrderNotesController < HelpfulableController
  before_action :set_load_order_note, only: [:show, :update, :destroy]

  # GET /load_order_notes
  # GET /load_order_notes.json
  def index
    @load_order_notes = LoadOrderNote.filter(filtering_params)

    render :json => @load_order_notes
  end

  # GET /load_order_notes/1
  # GET /load_order_notes/1.json
  def show
    render :json => @load_order_note
  end

  # POST /load_order_notes
  # POST /load_order_notes.json
  def create
    @load_order_note = LoadOrderNote.new(load_order_note_params)

    if load_order_note.save
      render json: {status: :ok}
    else
      render json: @load_order_note.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /load_order_notes/1
  # PATCH/PUT /load_order_notes/1.json
  def update
    if @load_order_note.update(load_order_note_params)
      render json: {status: :ok}
    else
      render json: @load_order_note.errors, status: :unprocessable_entity
    end
  end

  # DELETE /load_order_notes/1
  # DELETE /load_order_notes/1.json
  def destroy
    if @load_order_note.destroy
      render json: {status: :ok}
    else
      render json: @load_order_note.errors, status: :unprocessable_entity
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_load_order_note
      @load_order_note = LoadOrderNote.find(params[:id])
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
