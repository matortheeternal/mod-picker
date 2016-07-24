class ModListModsController < ApplicationController
  # POST /mod_list_mods
  def create
    @mod_list_mod = ModListMod.new(mod_list_mod_params)

    if @mod_list_mod.save
      # helper variables
      mod_ids = [ @mod_list_mod.mod_id ]
      mod_list = @mod_list_mod.mod_list

      # prepare requirements
      required_tools = ModRequirement.mods(mod_ids).utility(true)
      required_mods = ModRequirement.mods(mod_ids).utility(false)

      # prepare notes
      compatibility_notes = mod_list.mod_compatibility_notes.mod(mod_ids)
      install_order_notes = mod_list.install_order_notes.mod(mod_ids)

      # prepare helpful marks
      c_helpful_marks = HelpfulMark.submitter(current_user.id).helpfulable("CompatibilityNote", compatibility_notes.ids)
      i_helpful_marks = HelpfulMark.submitter(current_user.id).helpfulable("InstallOrderNote", install_order_notes.ids)

      # render response
      render json: {
          mod_list_mod: @mod_list_mod,
          required_tools: required_tools,
          required_mods: required_mods,
          compatibility_notes: compatibility_notes,
          install_order_notes: install_order_notes,
          c_helpful_marks: c_helpful_marks,
          i_helpful_marks: i_helpful_marks
      }
    else
      render json: @mod_list_mod.errors, status: :unprocessable_entity
    end
  end

  private
    def mod_list_mod_params
      params.require(:mod_list_mod).permit(:mod_list_id, :mod_id, :index)
    end
end
