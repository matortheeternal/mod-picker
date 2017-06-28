class Api::V1::RecordGroupsController < Api::ApiController
  # GET /record_groups
  def index
    if params.has_key?(:game_id)
      render json: static_cache("record_groups/#{params[:game_id]}") {
        RecordGroup.game(params[:game_id]).to_json
      }
    else
      render json: static_cache("record_groups") {
        RecordGroup.all.to_json
      }
    end
  end
end
