class Api::V1::PluginsController < Api::ApiController
  before_action :set_plugin, only: [:show, :destroy]

  # GET /plugins
  def index
    @plugins = Plugin.eager_load(:mod).accessible_by(current_ability).filter(filtering_params).sort(params[:sort]).paginate(page: params[:page])
    count =  Plugin.eager_load(:mod).accessible_by(current_ability).filter(filtering_params).count

    render json: {
        plugins: json_format(@plugins),
        max_entries: count,
        entries_per_page: Plugin.per_page
    }
  end

  # POST /plugins/search
  def search
    @plugins = Plugin.visible.filter(search_params).order("CHAR_LENGTH(filename)").limit(10)
    respond_with_json(@plugins, :base)
  end

  # GET /plugins/1
  def show
    authorize! :read, @plugin
    respond_with_json(@plugin)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_plugin
      @plugin = Plugin.find(params[:id])
    end

    # Params we allow filtering on
    def filtering_params
      params[:filters].slice(:adult, :hidden, :approved, :game, :search, :categories, :file_size, :records, :overrides, :errors, :mod_lists, :load_order_notes)
    end

    # Params we allow searching on
    def search_params
      if params[:filters].has_key?(:search)
        params[:filters][:search] = "filename:#{params[:filters][:search]}"
      end
      params[:filters].slice(:search, :game, :mods)
    end
end
