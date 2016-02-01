class ModVersionCompatibilityNotesController < ApplicationController
  before_action :set_mod_version_compatibility_note, only: [:show, :edit, :update, :destroy]

  # GET /mod_version_compatibility_notes
  # GET /mod_version_compatibility_notes.json
  def index
    @mod_version_compatibility_notes = ModVersionCompatibilityNote.all
    
    respond_to do |format|
      format.html
      format.json { render json: @mod_version_compatibility_notes }
    end
  end

  # GET /mod_version_compatibility_notes/1
  # GET /mod_version_compatibility_notes/1.json
  def show
    respond_to do |format|
      format.html
      format.json { render json: @mod_version_compatibility_note }
    end
  end

  # GET /mod_version_compatibility_notes/new
  def new
    @mod_version_compatibility_note = ModVersionCompatibilityNote.new
  end

  # GET /mod_version_compatibility_notes/1/edit
  def edit
  end

  # POST /mod_version_compatibility_notes
  # POST /mod_version_compatibility_notes.json
  def create
    @mod_version_compatibility_note = ModVersionCompatibilityNote.new(mod_version_compatibility_note_params)

    respond_to do |format|
      if @mod_version_compatibility_note.save
        format.html { redirect_to @mod_version_compatibility_note, notice: 'Mod version compatibility note map was successfully created.' }
        format.json { render :show, status: :created, location: @mod_version_compatibility_note }
      else
        format.html { render :new }
        format.json { render json: @mod_version_compatibility_note.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /mod_version_compatibility_notes/1
  # PATCH/PUT /mod_version_compatibility_notes/1.json
  def update
    respond_to do |format|
      if @mod_version_compatibility_note.update(mod_version_compatibility_note_params)
        format.html { redirect_to @mod_version_compatibility_note, notice: 'Mod version compatibility note map was successfully updated.' }
        format.json { render :show, status: :ok, location: @mod_version_compatibility_note }
      else
        format.html { render :edit }
        format.json { render json: @mod_version_compatibility_note.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /mod_version_compatibility_notes/1
  # DELETE /mod_version_compatibility_notes/1.json
  def destroy
    @mod_version_compatibility_note.destroy
    respond_to do |format|
      format.html { redirect_to mod_version_compatibility_notes_url, notice: 'Mod version compatibility note map was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_mod_version_compatibility_note
      @mod_version_compatibility_note = ModVersionCompatibilityNote.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def mod_version_compatibility_note_params
      params.require(:mod_version_compatibility_note).permit(:mod_version_id, :compatibility_note_id)
    end
end
