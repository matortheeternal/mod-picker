class Api::V1::TagsController < Api::ApiController
  # GET /all_tags
  def all
    @tags = Tag.game(params[:game])
    render json: @tags
  end

  # POST/GET /tags
  def index
    @tags = Tag.eager_load(:submitter).accessible_by(current_ability).filter(filtering_params).sort(params[:sort]).paginate(page: params[:page])
    count =  Tag.eager_load(:submitter).accessible_by(current_ability).filter(filtering_params).count

    render json: {
        tags: json_format(@tags),
        max_entries: count,
        entries_per_page: Tag.per_page
    }
  end

  private
    # Params we allow filtering on
    def filtering_params
      params[:filters].slice(:game, :hidden, :search, :submitter, :mods_count, :mod_lists_count)
    end

end