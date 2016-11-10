class RecordGroupsController < ApplicationController
  # GET /record_groups
  def index
    if params.has_key?(:game_id)
      @record_groups = RecordGroup.where(game_id: params[:game_id])
    else
      @record_groups = RecordGroup.all
    end

    render json: @record_groups
  end
end
