class HelpfulMarksController < ApplicationController
  before_action :set_helpful_mark, only: [:show, :edit, :update, :destroy]

  # GET /helpful_marks
  # GET /helpful_marks.json
  def index
    @helpful_marks = HelpfulMark.filter(filtering_params)

    respond_to do |format|
      format.html
      format.json { render :json => @helpful_marks}
    end
  end

  # GET /helpful_marks/1
  # GET /helpful_marks/1.json
  def show
    respond_to do |format|
      format.html
      format.json { render :json => @helpful_mark}
    end
  end

  # GET /helpful_marks/new
  def new
    @helpful_mark = HelpfulMark.new
  end

  # GET /helpful_marks/1/edit
  def edit
  end

  # POST /helpful_marks
  # POST /helpful_marks.json
  def create
    @helpful_mark = HelpfulMark.new(helpful_mark_params)

    respond_to do |format|
      if @helpful_mark.save
        format.json { render :show, status: :created, location: @helpful_mark }
      else
        format.json { render json: @helpful_mark.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /helpful_marks/1
  # PATCH/PUT /helpful_marks/1.json
  def update
    respond_to do |format|
      if @helpful_mark.update(helpful_mark_params)
        format.json { render :show, status: :ok, location: @helpful_mark }
      else
        format.json { render json: @helpful_mark.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /helpful_marks/1
  # DELETE /helpful_marks/1.json
  def destroy
    @helpful_mark.destroy
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_helpful_mark
      @helpful_mark = HelpfulMark.find_by(submitted_by: params[:submitted_by], helpfulable_id: params[:helpfulable_id], helpfulable_type: params[:helpfulable_type])
    end

    # Params we allow filtering on
    def filtering_params
      params.slice(:by);
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def helpful_mark_params
      params.require(:helpful_mark).permit(:submitted_by, :helpful, :helpfulable_id, :helpfulable_type)
    end
end
