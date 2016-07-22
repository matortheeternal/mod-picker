class ModListModsController < ApplicationController
  # GET /mod_list_mods/new
  # Renders the JSON for a new mod list mod
  def new
    if params.has_key?(:mod_id)
      @mod = Mod.find(params[:mod_id])
      authorize! :read, @mod

      @mod_list_mod = ModListMod.new(mod_id: @mod.id, index: 0)
      render json: {
          mod_list_mod: @mod_list_mod.new_json,
          requirements: @mod_list_mod.mod.required_mods
      }
    else
      render json: {error: "You must specify a mod_id to create a new ModListMod."}, status: 400
    end
  end
end
