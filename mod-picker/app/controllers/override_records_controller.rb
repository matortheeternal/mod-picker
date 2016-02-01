class OverrideRecordsController < ApplicationController
  before_action :set_override_record, only: [:show, :edit, :update, :destroy]

  # GET /override_records
  # GET /override_records.json
  def index
    @override_records = OverrideRecord.all

    respond_to do |format|
      format.html
      format.json { render :json => @override_records}
    end
  end

  # GET /override_records/1
  # GET /override_records/1.json
  def show
    respond_to do |format|
      format.html
      format.json { render :json => @override_record}
    end
  end

  # GET /override_records/new
  def new
    @override_record = OverrideRecord.new
  end

  # GET /override_records/1/edit
  def edit
  end

  # POST /override_records
  # POST /override_records.json
  def create
    @override_record = OverrideRecord.new(override_record_params)

    respond_to do |format|
      if @override_record.save
        format.html { redirect_to @override_record, notice: 'Override record was successfully created.' }
        format.json { render :show, status: :created, location: @override_record }
      else
        format.html { render :new }
        format.json { render json: @override_record.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /override_records/1
  # PATCH/PUT /override_records/1.json
  def update
    respond_to do |format|
      if @override_record.update(override_record_params)
        format.html { redirect_to @override_record, notice: 'Override record was successfully updated.' }
        format.json { render :show, status: :ok, location: @override_record }
      else
        format.html { render :edit }
        format.json { render json: @override_record.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /override_records/1
  # DELETE /override_records/1.json
  def destroy
    @override_record.destroy
    respond_to do |format|
      format.html { redirect_to override_records_url, notice: 'Override record was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_override_record
      @override_record = OverrideRecord.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def override_record_params
      params.require(:override_record).permit(:plugin_id, :master_id, :form_id)
    end
end
