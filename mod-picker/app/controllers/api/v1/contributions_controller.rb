class Api::V1::ContributionsController < Api::ApiController
  # GET /contribution/1
  def show
    authorize! :read, @contribution
    render json: @contribution
  end

  # POST/GET /contribution/1/corrections
  def corrections
    authorize! :read, @contribution

    # prepare corrections
    corrections = @contribution.corrections.accessible_by(current_ability)

    # render response
    render json: {
        corrections: corrections
    }
  end
end