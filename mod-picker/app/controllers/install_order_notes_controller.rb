class InstallOrderNotesController < ContributionsController
  before_action :set_install_order_note, only: [:show, :update, :approve, :hide, :destroy]

  # GET /install_order_notes
  # GET /install_order_notes.json
  def index
    @install_order_notes = InstallOrderNote.filter(filtering_params)

    render :json => @install_order_notes
  end

  # GET /install_order_notes/1
  # GET /install_order_notes/1.json
  def show
    render :json => @install_order_note
  end

  # POST /install_order_notes
  # POST /install_order_notes.json
  def create
    @install_order_note = InstallOrderNote.new(install_order_note_params)

    if install_order_note.save
      render json: {status: :ok}
    else
      render json: @install_order_note.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /install_order_notes/1
  # PATCH/PUT /install_order_notes/1.json
  def update
    if @install_order_note.update(install_order_note_params)
      render :show, status: :ok, location: install_order_note
    else
      render json: @install_order_note.errors, status: :unprocessable_entity
    end
  end

  # DELETE /install_order_notes/1
  # DELETE /install_order_notes/1.json
  def destroy
    if @install_order_note.destroy
      render json: {status: :ok}
    else
      render json: @install_order_note.errors, status: :unprocessable_entity
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_install_order_note
      @install_order_note = InstallOrderNote.find(params[:id])
    end

    # Params we allow filtering on
    def filtering_params
      params.slice(:by, :mod, :mv);
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def install_order_note_params
      params.require(:install_order_note).permit(:install_first, :install_second, :text_body)
    end
end
