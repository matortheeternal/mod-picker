class ModListModsController < ApplicationController
  # GET /mod_list_mods/new
  # Renders the JSON for a new mod list mod
  def new
    @mod = Mod.find(params[:mod_id])
    authorize! :read, @mod

    @mod_list_mod = ModListMod.new(mod_id: @mod.id, index: 0)
    render json: @mod_list_mod
  end
end
