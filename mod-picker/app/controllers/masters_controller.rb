class MastersController < ApplicationController
  before_action :set_master, only: [:show, :edit, :update, :destroy]

  # GET /masters
  # GET /masters.json
  def index
    @masters = Master.all

    respond_to do |format|
      format.html
      format.json { render :json => @masters}
    end
  end

  # GET /masters/1
  # GET /masters/1.json
  def show
    respond_to do |format|
      format.html
      format.json { render :json => @master}
    end
  end

  # GET /masters/new
  def new
    @master = Master.new
  end

  # GET /masters/1/edit
  def edit
  end

  # POST /masters
  # POST /masters.json
  def create
    @master = Master.new(master_params)

    respond_to do |format|
      if @master.save
        format.json { render :show, status: :created, location: @master }
      else
        format.json { render json: @master.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /masters/1
  # PATCH/PUT /masters/1.json
  def update
    respond_to do |format|
      if @master.update(master_params)
        format.json { render :show, status: :ok, location: @master }
      else
        format.json { render json: @master.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /masters/1
  # DELETE /masters/1.json
  def destroy
    @master.destroy
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_master
      @master = Master.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def master_params
      params.require(:master).permit(:plugin_id)
    end
end
