class Api::V1::ModOptionsController < Api::ApiController
  # POST /mod_options/search
  def search
    @mod_options = ModOption.filter(search_params).order("CHAR_LENGTH(display_name)").limit(10)
    render json: @mod_options
  end

  private
    # Params we allow searching on
    def search_params
      params[:filters].slice(:search, :mods)
    end

end
