class ContributionsController < ApplicationController
  # GET /contribution/1
  def show
    authorize! :read, @contribution
    render :json => @contribution
  end

  # PATCH/PUT /contribution/1
  def update
    authorize! :update, @contribution
    if @contribution.update(contribution_update_params)
      render json: {status: :ok}
    else
      render json: @contribution.errors, status: :unprocessable_entity
    end
  end

  # DELETE /contribution/1
  def destroy
    authorize! :destroy, @contribution
    if @contribution.destroy
      render json: {status: :ok}
    else
      render json: @contribution.errors, status: :unprocessable_entity
    end
  end

  # POST/GET /contribution/1/corrections
  def corrections
    authorize! :read, @contribution
    corrections = @contribution.corrections.accessible_by(current_ability)
    agreement_marks = AgreementMark.where(submitted_by: current_user.id, correction_id: corrections.ids)
    render :json => {
        corrections: corrections,
        agreement_marks: agreement_marks.as_json({:only => [:correction_id, :agree]})
    }
  end

  # POST/GET /contribution/1/history
  def history
    authorize! :read, @contribution
    history_entries = @contribution.history_entries.accessible_by(current_ability)
    render :json => history_entries
  end

  # POST /contribution/1/helpful
  def helpful
    # get old helpful marks
    old_helpful_marks = HelpfulMark.where(
        submitted_by: current_user.id,
        helpfulable_id: params[:id],
        helpfulable_type: controller_name.classify)

    if params.has_key?(:helpful)
      # create new helpful mark
      helpful_mark = HelpfulMark.new(
          submitted_by: current_user.id,
          helpfulable_id: params[:id],
          helpfulable_type: controller_name.classify,
          helpful: params[:helpful])

      if old_helpful_marks.destroy_all && helpful_mark.save
        render json: {status: :ok}
      else
        render json: (helpful_mark.errors + old_helpful_marks.errors), status: :unprocessable_entity
      end
    else
      if old_helpful_marks.destroy_all
        render json: {status: :ok}
      else
        render json: old_helpful_marks.errors, status: :unprocessable_entity
      end
    end
  end

  # POST /contribution/1/hide
  def hide
    authorize! :hide, @contribution
    @contribution.hidden = params[:hidden]
    if @contribution.save
      render json: {status: :ok}
    else
      render json: @contribution.errors, status: :unprocessable_entity
    end
  end

  # POST /contribution/1/approve
  def approve
    authorize! :approve, @contribution
    @contribution.approved = params[:approved]
    if @contribution.save
      render json: {status: :ok}
    else
      render json: @contribution.errors, status: :unprocessable_entity
    end
  end
end