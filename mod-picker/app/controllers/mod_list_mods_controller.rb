class ModListModsController < ApplicationController
  # POST /mod_list_mods
  def create
    @mod_list_mod = ModListMod.new(mod_list_mod_params)

    if @mod_list_mod.save
      mod_id = @mod_list_mod.mod_id
      required_tools = ModRequirement.where(mod_id: mod_id).joins(:mod).where(:mods => {is_utility: true})
      required_mods = ModRequirement.where(mod_id: mod_id).joins(:mod).where(:mods => {is_utility: false})
      render json: {
          mod_list_mod: @mod_list_mod,
          required_tools: required_tools,
          required_mods: required_mods
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
