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
    helpful_mark = HelpfulMark.find_or_create_by(
        submitted_by: current_user.id,
        helpfulable_id: params[:id],
        helpfulable_type: controller_name.classify)
    if params.has_key?(:helpful)
      helpful_mark.helpful = params[:helpful]
      if helpful_mark.save
        render json: {status: :ok}
      else
        render json: helpful_mark.errors, status: :unprocessable_entity
      end
    else
      if helpful_mark.destroy
        render json: {status: :ok}
      else
        render json: helpful_mark.errors, status: :unprocessable_entity
      end
    end
  end

  # POST /contribution/1/hide
  def hide
    authorize! :hide, @contribution
    @contribution.hidden = params[:hidden]
    if @contribution.save
      render json: {status: ok}
    else
      render json: @contribution.errors, status: :unprocessable_entity
    end
  end

  # POST /contribution/1/approve
  def approve
    authorize! :approve, @contribution
    @contribution.approved = params[:approved]
    if @contribution.save
      render json: {status: ok}
    else
      render json: @contribution.errors, status: :unprocessable_entity
    end
  end
end