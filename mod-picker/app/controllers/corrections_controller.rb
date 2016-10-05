class CorrectionsController < ApplicationController
  before_action :set_correction, only: [:show, :update, :comments, :hide, :destroy]

  # GET /corrections
  def index
    @corrections = Correction.preload(:editor).includes(:submitter => :reputation).references(:submitter => :reputation).accessible_by(current_ability).filter(filtering_params).sort(params[:sort]).paginate(:page => params[:page])
    count = Correction.accessible_by(current_ability).filter(filtering_params).count

    # get helpful marks
    agreement_marks = AgreementMark.where(submitted_by: current_user.id, correction_id: @corrections.ids)
    render :json => {
        corrections: Correction.index_json(@corrections),
        agreement_marks: agreement_marks,
        max_entries: count,
        entries_per_page: Correction.per_page
    }
  end

  # GET /corrections/1
  def show
    authorize! :read, @correction
    render :json => @correction
  end

  # POST /corrections
  def create
    @correction = Correction.new(correction_params)
    @correction.submitted_by = current_user.id
    authorize! :create, @correction

    if @correction.save
      render json: @correction.reload
    else
      render json: @correction.errors, status: :unprocessable_entity
    end
  end

  # POST/GET /corrections/1/comments
  def comments
    authorize! :read, @correction
    comments = @correction.comments.includes(:submitter => :reputation, :children => [:submitter => :reputation]).accessible_by(current_ability).sort(params[:sort]).paginate(:page => params[:page], :per_page => 10)
    count = @correction.comments.accessible_by(current_ability).count
    render :json => {
        comments: comments,
        max_entries: count,
        entries_per_page: 10
    }
  end

  # PATCH/PUT /corrections/1
  def update
    authorize! :update, @correction
    if @correction.update(correction_params)
      render json: {status: :ok}
    else
      render json: @correction.errors, status: :unprocessable_entity
    end
  end

  # POST /corrections/1/hide
  def hide
    authorize! :hide, @correction
    @correction.hidden = params[:hidden]
    if @correction.save
      render json: {status: :ok}
    else
      render json: @correction.errors, status: :unprocessable_entity
    end
  end

  # POST /corrections/1/agreement
  def agreement
    @agreement_mark = AgreementMark.find_or_initialize_by(
        submitted_by: current_user.id,
        correction_id: params[:id])
    if params.has_key?(:agree)
      @agreement_mark.agree = params[:agree]
      if @agreement_mark.save
        render json: {status: :ok}
      else
        render json: @agreement_mark.errors, status: :unprocessable_entity
      end
    else
      if @agreement_mark.destroy
        render json: {status: :ok}
      else
        render json: @agreement_mark.errors, status: :unprocessable_entity
      end
    end
  end

  # DELETE /corrections/1
  def destroy
    authorize! :destroy, @correction
    if @correction.destroy
      render json: {status: :ok}
    else
      render json: @correction.errors, status: :unprocessable_entity
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_correction
      @correction = Correction.find(params[:id])
    end

    # Params we allow filtering on
    def filtering_params
      params[:filters].slice(:adult, :game, :search, :submitter, :editor, :status, :mod_status, :correctable, :reputation, :agree_count, :disagree_count, :comments, :submitted, :edited);
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def correction_params
      params.require(:correction).permit(:game_id, :correctable_id, :correctable_type, :title, :text_body, :mod_status)
    end
end
