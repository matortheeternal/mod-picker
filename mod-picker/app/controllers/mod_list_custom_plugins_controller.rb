class ModListCustomPluginsController < ApplicationController
  before_action :set_mod_list_custom_plugin, only: [:update, :destroy]

  # POST /mod_list_custom_plugins
  # POST /mod_list_custom_plugins.json
  def create
    @mod_list_custom_plugin = ModListCustomPlugin.new(mod_list_custom_plugin_params)

    respond_to do |format|
      if @mod_list_custom_plugin.save
        format.json { render :show, status: :created, location: @mod_list_custom_plugin }
      else
        format.json { render json: @mod_list_custom_plugin.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /mod_list_custom_plugins/1
  # PATCH/PUT /mod_list_custom_plugins/1.json
  def update
    respond_to do |format|
      if @mod_list_custom_plugin.update(mod_list_custom_plugin_params)
        format.json { render :show, status: :ok, location: @mod_list_custom_plugin }
      else
        format.json { render json: @mod_list_custom_plugin.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /mod_list_custom_plugins/1
  # DELETE /mod_list_custom_plugins/1.json
  def destroy
    @mod_list_custom_plugin.destroy
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_mod_list_custom_plugin
      @mod_list_custom_plugin = ModListCustomPlugin.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def mod_list_custom_plugin_params
      params.require(:mod_list_custom_plugin).permit(:mod_list_id, :active, :load_order, :title, :description)
    end
end
