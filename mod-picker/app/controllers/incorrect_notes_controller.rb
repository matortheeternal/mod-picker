class IncorrectNotesController < ApplicationController
  before_action :set_incorrect_note, only: [:show, :edit, :update, :destroy]

  # GET /incorrect_notes
  # GET /incorrect_notes.json
  def index
    @incorrect_notes = IncorrectNote.all
  end

  # GET /incorrect_notes/1
  # GET /incorrect_notes/1.json
  def show
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
        format.html { redirect_to @incorrect_note, notice: 'Incorrect note was successfully created.' }
        format.json { render :show, status: :created, location: @incorrect_note }
      else
        format.html { render :new }
        format.json { render json: @incorrect_note.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /incorrect_notes/1
  # PATCH/PUT /incorrect_notes/1.json
  def update
    respond_to do |format|
      if @incorrect_note.update(incorrect_note_params)
        format.html { redirect_to @incorrect_note, notice: 'Incorrect note was successfully updated.' }
        format.json { render :show, status: :ok, location: @incorrect_note }
      else
        format.html { render :edit }
        format.json { render json: @incorrect_note.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /incorrect_notes/1
  # DELETE /incorrect_notes/1.json
  def destroy
    @incorrect_note.destroy
    respond_to do |format|
      format.html { redirect_to incorrect_notes_url, notice: 'Incorrect note was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_incorrect_note
      @incorrect_note = IncorrectNote.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def incorrect_note_params
      params.require(:incorrect_note).permit(:id, :review_id, :compatibility_note_id, :installation_note_id, :submitted_by, :reason)
    end
end
