class ModListPluginsController < ApplicationController
  before_action :set_mod_list_plugin, only: [:show, :edit, :update, :destroy]

  # GET /mod_list_plugins
  # GET /mod_list_plugins.json
  def index
    @mod_list_plugins = ModListPlugin.all
  end

  # GET /mod_list_plugins/1
  # GET /mod_list_plugins/1.json
  def show
  end

  # GET /mod_list_plugins/new
  def new
    @mod_list_plugin = ModListPlugin.new
  end

  # GET /mod_list_plugins/1/edit
  def edit
  end

  # POST /mod_list_plugins
  # POST /mod_list_plugins.json
  def create
    @mod_list_plugin = ModListPlugin.new(mod_list_plugin_params)

    respond_to do |format|
      if @mod_list_plugin.save
        format.html { redirect_to @mod_list_plugin, notice: 'Mod list plugin was successfully created.' }
        format.json { render :show, status: :created, location: @mod_list_plugin }
      else
        format.html { render :new }
        format.json { render json: @mod_list_plugin.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /mod_list_plugins/1
  # PATCH/PUT /mod_list_plugins/1.json
  def update
    respond_to do |format|
      if @mod_list_plugin.update(mod_list_plugin_params)
        format.html { redirect_to @mod_list_plugin, notice: 'Mod list plugin was successfully updated.' }
        format.json { render :show, status: :ok, location: @mod_list_plugin }
      else
        format.html { render :edit }
        format.json { render json: @mod_list_plugin.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /mod_list_plugins/1
  # DELETE /mod_list_plugins/1.json
  def destroy
    @mod_list_plugin.destroy
    respond_to do |format|
      format.html { redirect_to mod_list_plugins_url, notice: 'Mod list plugin was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_mod_list_plugin
      @mod_list_plugin = ModListPlugin.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def mod_list_plugin_params
      params.require(:mod_list_plugin).permit(:mod_list_id, :plugin_id, :active, :load_order)
    end
end
