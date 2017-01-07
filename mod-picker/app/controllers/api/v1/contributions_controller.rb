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

    # prepare agreement marks
    agreement_marks = AgreementMark.for_user_content(current_user, corrections.ids)

    # render response
    render json: {
        corrections: corrections,
        agreement_marks: agreement_marks
    }
  end

  # POST/GET /contribution/1/history
  def history
    authorize! :read, @contribution
    history_entries = @contribution.history_entries.accessible_by(current_ability)
    render json: history_entries
  end
end