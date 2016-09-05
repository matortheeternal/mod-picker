class ContributionsController < ApplicationController
  # GET /contribution/1
  def show
    authorize! :read, @contribution
    render :json => @contribution
  end

  # PATCH/PUT /contribution/1
  def update
    authorize! :update, @contribution
    update_params = contribution_update_params

    # create a history entry if the contribution has a create_history_entry method,
    # our update_params is not just a moderator messages,
    # and the user editing the contribution is not the last person to edit it
    if @contribution.respond_to?(:create_history_entry)
      last_edited_by = @contribution.edited_by
      if (update_params.keys - [:moderator_message]).any? && current_user.id != last_edited_by
        history_entry = @contribution.create_history_entry
      end
    end

    # update the base contribution
    update_params[:edited_by] = current_user.id
    if @contribution.update(update_params)
      render json: {status: :ok}
    else
      history_entry.delete if history_entry
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

    # prepare corrections
    corrections = @contribution.corrections.accessible_by(current_ability)

    # prepare agreement marks
    agreement_marks = AgreementMark.submitter(current_user.id).corrections(corrections.ids)

    # render response
    render :json => {
        corrections: corrections,
        agreement_marks: agreement_marks
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
    old_helpful_marks = HelpfulMark.submitter(current_user.id).helpfulables(controller_name.classify, params[:id])

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