class IncorrectNotesController < ApplicationController
  before_action :set_incorrect_note, only: [:show, :edit, :update, :destroy]

  # GET /incorrect_notes
  # GET /incorrect_notes.json
  def index
    @incorrect_notes = IncorrectNote.filter(filtering_params)

    respond_to do |format|
      format.html
      format.json { render :json => @incorrect_notes}
    end
  end

  # GET /incorrect_notes/1
  # GET /incorrect_notes/1.json
  def show
    respond_to do |format|
      format.html
      format.json { render :json => @incorrect_note}
    end
  end

  # GET /incorrect_notes/new
  def new
    @incorrect_note = IncorrectNote.new
  end

  # GET /incorrect_notes/1/edit
  def edit
  end

  # POST /incorrect_notes
  # POST /incorrect_notes.json
  def create
    @incorrect_note = IncorrectNote.new(incorrect_note_params)

    respond_to do |format|
      if @incorrect_note.save
        format.json { render :show, status: :created, location: @incorrect_note }
      else
        format.json { render json: @incorrect_note.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /incorrect_notes/1
  # PATCH/PUT /incorrect_notes/1.json
  def update
    respond_to do |format|
      if @incorrect_note.update(incorrect_note_params)
        format.json { render :show, status: :ok, location: @incorrect_note }
      else
        format.json { render json: @incorrect_note.errors, status: :unprocessable_entity }
      end
    end
  end

  # POST /incorrect_notes/1/agreement
  def agreement
    @agreement_mark = AgreementMark.find_or_create_by(
        submitted_by: current_user.id,
        incorrect_note_id: params[:id])
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

  # DELETE /incorrect_notes/1
  # DELETE /incorrect_notes/1.json
  def destroy
    @incorrect_note.destroy
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_incorrect_note
      @incorrect_note = IncorrectNote.find(params[:id])
    end

    # Params we allow filtering on
    def filtering_params
      params.slice(:by);
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def incorrect_note_params
      params.require(:incorrect_note).permit(:submitted_by, :reason, :correctable_id, :correctable_type)
    end
end
