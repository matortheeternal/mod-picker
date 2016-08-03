class ModListCustomPluginsController < ApplicationController

  def create
    @mod_list_custom_plugin = ModListCustomPlugin.new(mod_list_custom_plugin_params)

    if @mod_list_custom_plugin.save
      # render response
      render json: {
          mod_list_custom_plugin: @mod_list_custom_plugin
      }
    else
      render json: @mod_list_custom_plugin.errors, status: :unprocessable_entity
    end
  end

  private
    def mod_list_custom_plugin_params
      params.require(:mod_list_custom_plugin).permit(:mod_list_id, :group_id, :index, :filename, :description)
    end
end
