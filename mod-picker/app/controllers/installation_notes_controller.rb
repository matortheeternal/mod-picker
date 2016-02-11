class InstallationNotesController < ApplicationController
  before_action :set_installation_note, only: [:show, :edit, :update, :destroy]

  # GET /installation_notes
  # GET /installation_notes.json
  def index
    @installation_notes = InstallationNote.all

    respond_to do |format|
      format.html
      format.json { render :json => @installation_notes}
    end
  end

  # GET /installation_notes/1
  # GET /installation_notes/1.json
  def show
    respond_to do |format|
      format.html
      format.json { render :json => @installation_note}
    end
  end

  # GET /installation_notes/new
  def new
    @installation_note = InstallationNote.new
  end

  # GET /installation_notes/1/edit
  def edit
  end

  # POST /installation_notes
  # POST /installation_notes.json
  def create
    @installation_note = InstallationNote.new(installation_note_params)

    respond_to do |format|
      if @installation_note.save
        format.html { redirect_to @installation_note, notice: 'Installation note was successfully created.' }
        format.json { render :show, status: :created, location: @installation_note }
      else
        format.html { render :new }
        format.json { render json: @installation_note.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /installation_notes/1
  # PATCH/PUT /installation_notes/1.json
  def update
    respond_to do |format|
      if @installation_note.update(installation_note_params)
        format.html { redirect_to @installation_note, notice: 'Installation note was successfully updated.' }
        format.json { render :show, status: :ok, location: @installation_note }
      else
        format.html { render :edit }
        format.json { render json: @installation_note.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /installation_notes/1
  # DELETE /installation_notes/1.json
  def destroy
    @installation_note.destroy
    respond_to do |format|
      format.html { redirect_to installation_notes_url, notice: 'Installation note was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_installation_note
      @installation_note = InstallationNote.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def installation_note_params
      params.require(:installation_note).permit(:submitted_by, :mod_version_id, :always, :note_type, :submitted, :edited, :text_body)
    end
end
