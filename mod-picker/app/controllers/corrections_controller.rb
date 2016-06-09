class CorrectionsController < ApplicationController
  before_action :set_correction, only: [:show, :edit, :update, :destroy]

  # GET /corrections
  # GET /corrections.json
  def index
    @corrections = Correction.filter(filtering_params)

    render :json => @corrections
  end

  # GET /corrections/1
  # GET /corrections/1.json
  def show
    render :json => @correction
  end

  # GET /corrections/new
  def new
    @correction = Correction.new
  end

  # GET /corrections/1/edit
  def edit
  end

  # POST /corrections
  # POST /corrections.json
  def create
    @correction = Correction.new(correction_params)

    if @correction.save
      render json: {status: :ok}
    else
      render json: @correction.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /corrections/1
  # PATCH/PUT /corrections/1.json
  def update
    if @correction.update(correction_params)
      render json: {status: :ok}
    else
      render json: @correction.errors, status: :unprocessable_entity
    end
  end

  # POST /corrections/1/agreement
  def agreement
    @agreement_mark = AgreementMark.find_or_create_by(
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
  # DELETE /corrections/1.json
  def destroy
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
      params.slice(:by);
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def correction_params
      params.require(:correction).permit(:game_id, :correctable_id, :correctable_type, :title, :text_body, :mod_status)
    end
end
