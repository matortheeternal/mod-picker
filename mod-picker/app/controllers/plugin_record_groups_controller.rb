class PluginRecordGroupsController < ApplicationController
  before_action :set_plugin_record_group, only: [:show, :edit, :update, :destroy]

  # GET /plugin_record_groups
  # GET /plugin_record_groups.json
  def index
    @plugin_record_groups = PluginRecordGroup.all

    respond_to do |format|
      format.html
      format.json { render :json => @plugin_record_groups}
    end
  end

  # GET /plugin_record_groups/1
  # GET /plugin_record_groups/1.json
  def show
    respond_to do |format|
      format.html
      format.json { render :json => @plugin_record_group}
    end
  end

  # GET /plugin_record_groups/new
  def new
    @plugin_record_group = PluginRecordGroup.new
  end

  # GET /plugin_record_groups/1/edit
  def edit
  end

  # POST /plugin_record_groups
  # POST /plugin_record_groups.json
  def create
    @plugin_record_group = PluginRecordGroup.new(plugin_record_group_params)

    respond_to do |format|
      if @plugin_record_group.save
        format.html { redirect_to @plugin_record_group, notice: 'Plugin record group was successfully created.' }
        format.json { render :show, status: :created, location: @plugin_record_group }
      else
        format.html { render :new }
        format.json { render json: @plugin_record_group.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /plugin_record_groups/1
  # PATCH/PUT /plugin_record_groups/1.json
  def update
    respond_to do |format|
      if @plugin_record_group.update(plugin_record_group_params)
        format.html { redirect_to @plugin_record_group, notice: 'Plugin record group was successfully updated.' }
        format.json { render :show, status: :ok, location: @plugin_record_group }
      else
        format.html { render :edit }
        format.json { render json: @plugin_record_group.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /plugin_record_groups/1
  # DELETE /plugin_record_groups/1.json
  def destroy
    @plugin_record_group.destroy
    respond_to do |format|
      format.html { redirect_to plugin_record_groups_url, notice: 'Plugin record group was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_plugin_record_group
      @plugin_record_group = PluginRecordGroup.find_by(plugin_id: params[:plugin_id], sig: params[:sig])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def plugin_record_group_params
      params.require(:plugin_record_group).permit(:plugin_id, :sig, :name, :new_records, :override_records)
    end
end
