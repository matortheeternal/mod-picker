class PluginsController < ApplicationController
  before_action :set_plugin, only: [:show, :destroy]

  # GET /plugins
  def index
    @plugins = Plugin.accessible_by(current_ability).filter(filtering_params).sort(params[:sort]).paginate(:page => params[:page])

    render :json => Plugin.index_json(@plugins)
  end

  # POST /plugins/search
  def search
    @plugins = Plugin.filter(search_params).sort({ column: "filename", direction: "ASC" }).limit(10)

    render :json => @plugins
  end

  # GET /plugins/1
  def show
    authorize! :read, @plugin
    render :json => Plugin.show_json(@plugin)
  end

  # DELETE /plugins/1
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

    # Params we allow filtering on
    def filtering_params
      params[:filters].permit(:search, :game)
    end

    # Params we allow searching on
    def search_params
      params[:filters].permit(:search, :game)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def plugin_params
      params.require(:plugin).permit(:mod_version_id, :filename, :author, :description, :hash)
    end
end
