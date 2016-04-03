class AgreementMarksController < ApplicationController
  before_action :set_agreement_mark, only: [:show, :edit, :update, :destroy]

  # GET /agreement_marks
  # GET /agreement_marks.json
  def index
    @agreement_marks = AgreementMark.all

    respond_to do |format|
      format.json { render :json => @agreement_marks}
    end
  end

  # GET /agreement_marks/1
  # GET /agreement_marks/1.json
  def show
    respond_to do |format|
      format.json { render :json => @agreement_mark}
    end
  end

  # GET /agreement_marks/new
  def new
    @agreement_mark = AgreementMark.new
  end

  # GET /agreement_marks/1/edit
  def edit
  end

  # POST /agreement_marks
  # POST /agreement_marks.json
  def create
    @agreement_mark = AgreementMark.new(agreement_mark_params)

    respond_to do |format|
      if @agreement_mark.save
        format.json { render :show, status: :created, location: @agreement_mark }
      else
        format.json { render json: @agreement_mark.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /agreement_marks/1
  # PATCH/PUT /agreement_marks/1.json
  def update
    respond_to do |format|
      if @agreement_mark.update(agreement_mark_params)
        format.json { render :show, status: :ok, location: @agreement_mark }
      else
        format.json { render json: @agreement_mark.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /agreement_marks/1
  # DELETE /agreement_marks/1.json
  def destroy
    @agreement_mark.destroy
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_agreement_mark
      @agreement_mark = AgreementMark.find_by(incorrect_note_id: params[:incorrect_note_id], submitted_by: params[:submitted_by])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def agreement_mark_params
      params.require(:agreement_mark).permit(:incorrect_note_id, :submitted_by, :agree)
    end
end
