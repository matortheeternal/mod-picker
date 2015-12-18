class PluginOverrideMapsController < ApplicationController
  before_action :set_plugin_override_map, only: [:show, :edit, :update, :destroy]

  # GET /plugin_override_maps
  # GET /plugin_override_maps.json
  def index
    @plugin_override_maps = PluginOverrideMap.all
  end

  # GET /plugin_override_maps/1
  # GET /plugin_override_maps/1.json
  def show
  end

  # GET /plugin_override_maps/new
  def new
    @plugin_override_map = PluginOverrideMap.new
  end

  # GET /plugin_override_maps/1/edit
  def edit
  end

  # POST /plugin_override_maps
  # POST /plugin_override_maps.json
  def create
    @plugin_override_map = PluginOverrideMap.new(plugin_override_map_params)

    respond_to do |format|
      if @plugin_override_map.save
        format.html { redirect_to @plugin_override_map, notice: 'Plugin override map was successfully created.' }
        format.json { render :show, status: :created, location: @plugin_override_map }
      else
        format.html { render :new }
        format.json { render json: @plugin_override_map.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /plugin_override_maps/1
  # PATCH/PUT /plugin_override_maps/1.json
  def update
    respond_to do |format|
      if @plugin_override_map.update(plugin_override_map_params)
        format.html { redirect_to @plugin_override_map, notice: 'Plugin override map was successfully updated.' }
        format.json { render :show, status: :ok, location: @plugin_override_map }
      else
        format.html { render :edit }
        format.json { render json: @plugin_override_map.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /plugin_override_maps/1
  # DELETE /plugin_override_maps/1.json
  def destroy
    @plugin_override_map.destroy
    respond_to do |format|
      format.html { redirect_to plugin_override_maps_url, notice: 'Plugin override map was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_plugin_override_map
      @plugin_override_map = PluginOverrideMap.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def plugin_override_map_params
      params.require(:plugin_override_map).permit(:pl_id, :mst_id, :form_id, :sig, :name, :is_itm, :is_itpo, :is_udr)
    end
end
