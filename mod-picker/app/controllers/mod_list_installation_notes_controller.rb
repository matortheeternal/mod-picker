class ModListInstallationNotesController < ApplicationController
  before_action :set_mod_list_installation_note, only: [:show, :edit, :update, :destroy]

  # GET /mod_list_installation_notes
  # GET /mod_list_installation_notes.json
  def index
    @mod_list_installation_notes = ModListInstallationNote.all

    respond_to do |format|
      format.html
      format.json { render :json => @mod_list_installation_notes}
    end
  end

  # GET /mod_list_installation_notes/1
  # GET /mod_list_installation_notes/1.json
  def show
    respond_to do |format|
      format.html
      format.json { render :json => @mod_list_installation_note}
    end
  end

  # GET /mod_list_installation_notes/new
  def new
    @mod_list_installation_note = ModListInstallationNote.new
  end

  # GET /mod_list_installation_notes/1/edit
  def edit
  end

  # POST /mod_list_installation_notes
  # POST /mod_list_installation_notes.json
  def create
    @mod_list_installation_note = ModListInstallationNote.new(mod_list_installation_note_params)

    respond_to do |format|
      if @mod_list_installation_note.save
        format.html { redirect_to @mod_list_installation_note, notice: 'Mod list installation note was successfully created.' }
        format.json { render :show, status: :created, location: @mod_list_installation_note }
      else
        format.html { render :new }
        format.json { render json: @mod_list_installation_note.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /mod_list_installation_notes/1
  # PATCH/PUT /mod_list_installation_notes/1.json
  def update
    respond_to do |format|
      if @mod_list_installation_note.update(mod_list_installation_note_params)
        format.html { redirect_to @mod_list_installation_note, notice: 'Mod list installation note was successfully updated.' }
        format.json { render :show, status: :ok, location: @mod_list_installation_note }
      else
        format.html { render :edit }
        format.json { render json: @mod_list_installation_note.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /mod_list_installation_notes/1
  # DELETE /mod_list_installation_notes/1.json
  def destroy
    @mod_list_installation_note.destroy
    respond_to do |format|
      format.html { redirect_to mod_list_installation_notes_url, notice: 'Mod list installation note was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_mod_list_installation_note
      @mod_list_installation_note = ModListInstallationNote.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def mod_list_installation_note_params
      params.require(:mod_list_installation_note).permit(:mod_list_id, :installation_note_id, :status)
    end
end
