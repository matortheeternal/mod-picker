class ModListCompatibilityNotesController < ApplicationController
  before_action :set_mod_list_compatibility_note, only: [:update]

  # PATCH/PUT /mod_list_compatibility_notes/1
  # PATCH/PUT /mod_list_compatibility_notes/1.json
  def update
    authorize! :update, @mod_list_compatibility_note
    if @mod_list_compatibility_note.update(mod_list_compatibility_note_params)
      render json: {status: :ok}
    else
      render json: @mod_list_compatibility_note.errors, status: :unprocessable_entity
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
