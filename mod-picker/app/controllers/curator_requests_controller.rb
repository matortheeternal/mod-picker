class CuratorRequestsController < ApplicationController
  before_action :set_curator_request, only: [:update]

  # POST /curator_requests/index
  def index
    @curator_requests = CuratorRequest.eager_load(:mod, :submitter => :reputation).accessible_by(current_ability).filter(filtering_params).sort(sorting_params).paginate(page: params[:page])
    count =  CuratorRequest.eager_load(:mod, :submitter => :reputation).accessible_by(current_ability).filter(filtering_params).count

    render json: {
        curator_requests: @curator_requests,
        max_entries: count,
        entries_per_page: CuratorRequest.per_page
    }
  end

  # POST /curator_requests
  def create
    @curator_request = CuratorRequest.new(curator_request_params)
    @curator_request.submitted_by = current_user.id
    authorize! :create, @curator_request

    if @curator_request.save
      render json: { status: :ok }
    else
      render json: @curator_request.errors, status: :unprocessable_entity
    end
  end

  # PATCH /curator_request/1
  def update
    authorize! :update, @curator_request
    if @curator_request.update(curator_request_update_params)
      render json: {status: :ok}
    else
      render json: @curator_request.errors, status: :unprocessable_entity
    end
  end

  private
    def set_curator_request
      @curator_request = CuratorRequest.find(params[:id])
    end

    def curator_request_params
      params.require(:curator_request).permit(:mod_id, :text_body)
    end

    def curator_request_update_params
      params.require(:curator_request).permit(:state)
    end

    # Params we allow sorting on
    def sorting_params
      params.fetch(:sort, {}).permit(:column, :direction)
    end

    # Params we allow filtering on
    def filtering_params
      params[:filters].slice(:game, :search, :submitter, :mod_name, :state, :submitted, :updated)
    end

end
