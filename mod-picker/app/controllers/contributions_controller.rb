class ContributionsController < ApplicationController
  # GET /contribution/1
  def show
    authorize! :read, @contribution
    render :json => @contribution
  end

  # PATCH/PUT /contribution/1
  def update
    authorize! :update, @contribution
    if @contribution.update(contribution_params)
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