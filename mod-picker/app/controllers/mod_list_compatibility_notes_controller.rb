class ModListCompatibilityNotesController < ApplicationController
  before_action :set_mod_list_compatibility_note, only: [:update]

  # PATCH/PUT /mod_list_compatibility_notes/1
  # PATCH/PUT /mod_list_compatibility_notes/1.json
  def update
    respond_to do |format|
      if @mod_list_compatibility_note.update(mod_list_compatibility_note_params)
        format.json { render :show, status: :ok, location: @mod_list_compatibility_note }
      else
        format.json { render json: @mod_list_compatibility_note.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_mod_list_compatibility_note
      @mod_list_compatibility_note = ModListCompatibilityNote.find_by(mod_list_id: params[:mod_list_id], compatibility_note_id: params[:compatibility_note_id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def mod_list_compatibility_note_params
      params.require(:mod_list_compatibility_note).permit(:mod_list_id, :compatibility_note_id, :status)
    end
end
