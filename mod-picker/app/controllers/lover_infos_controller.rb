class LoverInfosController < ApplicationController
  before_action :set_lover_info, only: [:show, :edit, :update, :destroy]

  # GET /lover_infos
  # GET /lover_infos.json
  def index
    @lover_infos = LoverInfo.all

    respond_to do |format|
      format.html
      format.json { render :json => @lover_infos}
    end
  end

  # GET /lover_infos/1
  # GET /lover_infos/1.json
  def show
    respond_to do |format|
      format.html
      format.json { render :json => @lover_info}
    end
  end

  # GET /lover_infos/new
  def new
    @lover_info = LoverInfo.new
  end

  # GET /lover_infos/1/edit
  def edit
  end

  # POST /lover_infos
  # POST /lover_infos.json
  def create
    @lover_info = LoverInfo.new(lover_info_params)

    respond_to do |format|
      if @lover_info.save
        format.html { redirect_to @lover_info, notice: 'Lover info was successfully created.' }
        format.json { render :show, status: :created, location: @lover_info }
      else
        format.html { render :new }
        format.json { render json: @lover_info.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /lover_infos/1
  # PATCH/PUT /lover_infos/1.json
  def update
    respond_to do |format|
      if @lover_info.update(lover_info_params)
        format.html { redirect_to @lover_info, notice: 'Lover info was successfully updated.' }
        format.json { render :show, status: :ok, location: @lover_info }
      else
        format.html { render :edit }
        format.json { render json: @lover_info.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /lover_infos/1
  # DELETE /lover_infos/1.json
  def destroy
    @lover_info.destroy
    respond_to do |format|
      format.html { redirect_to lover_infos_url, notice: 'Lover info was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_lover_info
      @lover_info = LoverInfo.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def lover_info_params
      params.require(:lover_info).permit(:id, :mod_id)
    end
end
