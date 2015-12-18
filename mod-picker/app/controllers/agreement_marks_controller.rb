class AgreementMarksController < ApplicationController
  before_action :set_agreement_mark, only: [:show, :edit, :update, :destroy]

  # GET /agreement_marks
  # GET /agreement_marks.json
  def index
    @agreement_marks = AgreementMark.all
  end

  # GET /agreement_marks/1
  # GET /agreement_marks/1.json
  def show
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
        format.html { redirect_to @agreement_mark, notice: 'Agreement mark was successfully created.' }
        format.json { render :show, status: :created, location: @agreement_mark }
      else
        format.html { render :new }
        format.json { render json: @agreement_mark.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /agreement_marks/1
  # PATCH/PUT /agreement_marks/1.json
  def update
    respond_to do |format|
      if @agreement_mark.update(agreement_mark_params)
        format.html { redirect_to @agreement_mark, notice: 'Agreement mark was successfully updated.' }
        format.json { render :show, status: :ok, location: @agreement_mark }
      else
        format.html { render :edit }
        format.json { render json: @agreement_mark.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /agreement_marks/1
  # DELETE /agreement_marks/1.json
  def destroy
    @agreement_mark.destroy
    respond_to do |format|
      format.html { redirect_to agreement_marks_url, notice: 'Agreement mark was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_agreement_mark
      @agreement_mark = AgreementMark.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def agreement_mark_params
      params.require(:agreement_mark).permit(:inc_id, :submitted_by, :agree)
    end
end
