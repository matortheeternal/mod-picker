class WorkshopInfosController < ApplicationController
  before_action :set_workshop_info, only: [:show, :edit, :update, :destroy]

  # GET /workshop_infos
  # GET /workshop_infos.json
  def index
    @workshop_infos = WorkshopInfo.all
  end

  # GET /workshop_infos/1
  # GET /workshop_infos/1.json
  def show
  end

  # GET /workshop_infos/new
  def new
    @workshop_info = WorkshopInfo.new
  end

  # GET /workshop_infos/1/edit
  def edit
  end

  # POST /workshop_infos
  # POST /workshop_infos.json
  def create
    @workshop_info = WorkshopInfo.new(workshop_info_params)

    respond_to do |format|
      if @workshop_info.save
        format.html { redirect_to @workshop_info, notice: 'Workshop info was successfully created.' }
        format.json { render :show, status: :created, location: @workshop_info }
      else
        format.html { render :new }
        format.json { render json: @workshop_info.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /workshop_infos/1
  # PATCH/PUT /workshop_infos/1.json
  def update
    respond_to do |format|
      if @workshop_info.update(workshop_info_params)
        format.html { redirect_to @workshop_info, notice: 'Workshop info was successfully updated.' }
        format.json { render :show, status: :ok, location: @workshop_info }
      else
        format.html { render :edit }
        format.json { render json: @workshop_info.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /workshop_infos/1
  # DELETE /workshop_infos/1.json
  def destroy
    @workshop_info.destroy
    respond_to do |format|
      format.html { redirect_to workshop_infos_url, notice: 'Workshop info was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_workshop_info
      @workshop_info = WorkshopInfo.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def workshop_info_params
      params.require(:workshop_info).permit(:id, :mod_id)
    end
end
