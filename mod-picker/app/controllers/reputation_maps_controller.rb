class ReputationMapsController < ApplicationController
  before_action :set_reputation_map, only: [:show, :edit, :update, :destroy]

  # GET /reputation_maps
  # GET /reputation_maps.json
  def index
    @reputation_maps = ReputationMap.all
  end

  # GET /reputation_maps/1
  # GET /reputation_maps/1.json
  def show
  end

  # GET /reputation_maps/new
  def new
    @reputation_map = ReputationMap.new
  end

  # GET /reputation_maps/1/edit
  def edit
  end

  # POST /reputation_maps
  # POST /reputation_maps.json
  def create
    @reputation_map = ReputationMap.new(reputation_map_params)

    respond_to do |format|
      if @reputation_map.save
        format.html { redirect_to @reputation_map, notice: 'Reputation map was successfully created.' }
        format.json { render :show, status: :created, location: @reputation_map }
      else
        format.html { render :new }
        format.json { render json: @reputation_map.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /reputation_maps/1
  # PATCH/PUT /reputation_maps/1.json
  def update
    respond_to do |format|
      if @reputation_map.update(reputation_map_params)
        format.html { redirect_to @reputation_map, notice: 'Reputation map was successfully updated.' }
        format.json { render :show, status: :ok, location: @reputation_map }
      else
        format.html { render :edit }
        format.json { render json: @reputation_map.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /reputation_maps/1
  # DELETE /reputation_maps/1.json
  def destroy
    @reputation_map.destroy
    respond_to do |format|
      format.html { redirect_to reputation_maps_url, notice: 'Reputation map was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_reputation_map
      @reputation_map = ReputationMap.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def reputation_map_params
      params.require(:reputation_map).permit(:from_rep_id, :to_rep_id)
    end
end
