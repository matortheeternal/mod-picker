class ModListPluginsController < ApplicationController
  def create
    @mod_list_plugin = ModListPlugin.new(mod_list_plugin_params)
    authorize! :read, @mod_list_plugin.plugin
    authorize! :update, @mod_list_plugin.mod_list

    if @mod_list_plugin.save
      render json: {
          mod_list_plugin: @mod_list_plugin,
          required_plugins: @mod_list_plugin.required_plugins
      }
    else
      render json: @mod_list_plugin.errors, status: :unprocessable_entity
    end
  end

  private
    def mod_list_plugin_params
      params.require(:mod_list_plugin).permit(:mod_list_id, :plugin_id, :index)
    end
end
