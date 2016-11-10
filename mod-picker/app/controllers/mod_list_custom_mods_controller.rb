class ModListCustomModsController < ApplicationController

  def create
    @mod_list_custom_mod = ModListCustomMod.new(mod_list_custom_mod_params)
    authorize! :update, @mod_list_custom_mod.mod_list

    if @mod_list_custom_mod.save
      # render response
      render json: {
          mod_list_custom_mod: @mod_list_custom_mod
      }
    else
      render json: @mod_list_custom_mod.errors, status: :unprocessable_entity
    end
  end

  private
    def mod_list_custom_mod_params
      params.require(:mod_list_custom_mod).permit(:mod_list_id, :group_id, :is_utility, :index, :name, :description)
    end
end
