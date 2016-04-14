class ModListPluginsController < ApplicationController
  before_action :set_mod_list_plugin, only: [:update, :destroy]

  # POST /mod_list_plugins
  # POST /mod_list_plugins.json
  def create
    @mod_list_plugin = ModListPlugin.new(mod_list_plugin_params)

    if @mod_list_plugin.save
      render json: {status: :ok}
    else
      render json: @mod_list_plugin.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /mod_list_plugins/1
  # PATCH/PUT /mod_list_plugins/1.json
  def update
    if @mod_list_plugin.update(mod_list_plugin_params)
      render json: {status: :ok}
    else
      render json: @mod_list_plugin.errors, status: :unprocessable_entity
    end
  end

  # DELETE /mod_list_plugins/1
  # DELETE /mod_list_plugins/1.json
  def destroy
    if @mod_list_plugin.destroy
      render json: {status: :ok}
    else
      render json: @mod_list_plugin.errors, status: :unprocessable_entity
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_mod_list_plugin
      @mod_list_plugin = ModListPlugin.find_by(mod_list_id: params[:mod_list_id], plugin_id: params[:plugin_id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def mod_list_plugin_params
      params.require(:mod_list_plugin).permit(:mod_list_id, :plugin_id, :active, :load_order)
    end
end
