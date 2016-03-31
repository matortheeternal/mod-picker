class InstallOrderNotesController < ApplicationController
  before_action :set_install_order_note, only: [:show, :edit, :update, :destroy]

  # GET /install_order_notes
  # GET /install_order_notes.json
  def index
    install_order_notes = InstallOrderNote.filter(filtering_params)

    respond_to do |format|
      format.html
      format.json { render :json => install_order_notes}
    end
  end

  # GET /install_order_notes/1
  # GET /install_order_notes/1.json
  def show
    respond_to do |format|
      format.html
      format.json { render :json => install_order_note}
    end
  end

  # GET /install_order_notes/new
  def new
    install_order_note = InstallOrderNote.new
  end

  # GET /install_order_notes/1/edit
  def edit
  end

  # POST /install_order_notes
  # POST /install_order_notes.json
  def create
    install_order_note = InstallOrderNote.new(install_order_note_params)

    respond_to do |format|
      if install_order_note.save
        format.html { redirect_to install_order_note, notice: 'Install order note was successfully created.' }
        format.json { render :show, status: :created, location: install_order_note }
      else
        format.html { render :new }
        format.json { render json: install_order_note.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /install_order_notes/1
  # PATCH/PUT /install_order_notes/1.json
  def update
    respond_to do |format|
      if install_order_note.update(install_order_note_params)
        format.html { redirect_to install_order_note, notice: 'Install order note was successfully updated.' }
        format.json { render :show, status: :ok, location: install_order_note }
      else
        format.html { render :edit }
        format.json { render json: install_order_note.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /install_order_notes/1
  # DELETE /install_order_notes/1.json
  def destroy
    install_order_note.destroy
    respond_to do |format|
      format.html { redirect_to install_order_notes_url, notice: 'Install order note was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_install_order_note
      install_order_note = InstallOrderNote.find(params[:id])
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
