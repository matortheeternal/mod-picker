class PluginsController < ApplicationController
  before_action :set_plugin, only: [:show, :edit, :update, :destroy]

  # GET /plugins
  # GET /plugins.json
  def index
    @plugins = Plugin.all

    respond_to do |format|
      format.html
      format.json { render :json => @plugins}
    end
  end

  # GET /plugins/1
  # GET /plugins/1.json
  def show
    respond_to do |format|
      format.html
      format.json { render :json => @plugin}
    end
  end

  # GET /plugins/new
  def new
    @plugin = Plugin.new
  end

  # GET /plugins/1/edit
  def edit
  end

  # POST /plugins
  def create
    response = 'Invalid submission'
    if params[:plugin].present?
      file = params[:plugin]
      if File.exists?(Rails.root.join('app','assets', 'plugins', file.original_filename))
        response = 'File exists'
      else
        begin
          File.open(Rails.root.join('app','assets', 'plugins', file.original_filename), 'wb') do |f|
            f.write(file.read)
          end
          response = 'Success'
        rescue
          response = 'Unknown failure'
        end
      end
    end

    # render json response
    render json: {status: response}
  end

  # PATCH/PUT /plugins/1
  # PATCH/PUT /plugins/1.json
  def update
    respond_to do |format|
      if @plugin.update(plugin_params)
        format.json { render :show, status: :ok, location: @plugin }
      else
        format.json { render json: @plugin.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /plugins/1
  # DELETE /plugins/1.json
  def destroy
    @plugin.destroy
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_plugin
      @plugin = Plugin.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def plugin_params
      params.require(:plugin).permit(:mod_version_id, :filename, :author, :description, :hash)
    end
end
