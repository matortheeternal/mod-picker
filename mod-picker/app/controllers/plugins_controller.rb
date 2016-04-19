class PluginsController < ApplicationController
  before_action :set_plugin, only: [:show, :destroy]

  # GET /plugins
  # GET /plugins.json
  def index
    @plugins = Plugin.all

    render :json => @plugins
  end

  # GET /plugins/1
  # GET /plugins/1.json
  def show
    authorize! :read, @plugin
    render :json => @plugin
  end

  # POST /plugins
  def create
    authorize! :submit, :mod
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

  # DELETE /plugins/1
  # DELETE /plugins/1.json
  def destroy
    authorize! :destroy, @plugin
    if @plugin.destroy
      render json: {status: :ok}
    else
      render json: @plugin.errors, status: :unprocessable_entity
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
