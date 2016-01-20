class PluginOverridesController < ApplicationController
  before_action :set_plugin_override, only: [:show, :edit, :update, :destroy]

  # GET /plugin_overrides
  # GET /plugin_overrides.json
  def index
    @plugin_overrides = PluginOverride.all
  end

  # GET /plugin_overrides/1
  # GET /plugin_overrides/1.json
  def show
  end

  # GET /plugin_overrides/new
  def new
    @plugin_override = PluginOverride.new
  end

  # GET /plugin_overrides/1/edit
  def edit
  end

  # POST /plugin_overrides
  # POST /plugin_overrides.json
  def create
    @plugin_override = PluginOverride.new(plugin_override_params)

    respond_to do |format|
      if @plugin_override.save
        format.html { redirect_to @plugin_override, notice: 'Plugin override map was successfully created.' }
        format.json { render :show, status: :created, location: @plugin_override }
      else
        format.html { render :new }
        format.json { render json: @plugin_override.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /plugin_overrides/1
  # PATCH/PUT /plugin_overrides/1.json
  def update
    respond_to do |format|
      if @plugin_override.update(plugin_override_params)
        format.html { redirect_to @plugin_override, notice: 'Plugin override map was successfully updated.' }
        format.json { render :show, status: :ok, location: @plugin_override }
      else
        format.html { render :edit }
        format.json { render json: @plugin_override.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /plugin_overrides/1
  # DELETE /plugin_overrides/1.json
  def destroy
    @plugin_override.destroy
    respond_to do |format|
      format.html { redirect_to plugin_overrides_url, notice: 'Plugin override map was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_plugin_override
      @plugin_override = PluginOverride.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def plugin_override_params
      params.require(:plugin_override).permit(:plugin_id, :master_id, :form_id)
    end
end
