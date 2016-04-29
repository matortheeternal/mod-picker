class ModListLoadOrderNotesController < ApplicationController
  before_action :set_mod_list_load_order_note, only: [:update, :destroy]

  # PATCH/PUT /mod_list_load_order_notes/1
  # PATCH/PUT /mod_list_load_order_notes/1.json
  def update
    authorize! :update, @mod_list_load_order_note
    if @mod_list_load_order_note.update(mod_list_load_order_note_params)
      render json: {status: :ok}
    else
      render json: @mod_list_load_order_note.errors, status: :unprocessable_entity
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_mod_list_load_order_note
      @mod_list_load_order_note = ModListLoadOrderNote.find_by(mod_list_id: params[:mod_list_id], load_order_note_id: params[:load_order_note_id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def mod_list_load_order_note_params
      params.require(:mod_list_load_order_note).permit(:mod_list_id, :load_order_note_id, :status)
    end
end
