class ModVersionCompatibilityNoteMapsController < ApplicationController
  before_action :set_mod_version_compatibility_note_map, only: [:show, :edit, :update, :destroy]

  # GET /mod_version_compatibility_note_maps
  # GET /mod_version_compatibility_note_maps.json
  def index
    @mod_version_compatibility_note_maps = ModVersionCompatibilityNoteMap.all
    
    respond_to do |format|
      format.html
      format.json { render json: @mod_version_compatibility_note_maps }
    end
  end

  # GET /mod_version_compatibility_note_maps/1
  # GET /mod_version_compatibility_note_maps/1.json
  def show
    respond_to do |format|
      format.html
      format.json { render json: @mod_version_compatibility_note_map }
    end
  end

  # GET /mod_version_compatibility_note_maps/new
  def new
    @mod_version_compatibility_note_map = ModVersionCompatibilityNoteMap.new
  end

  # GET /mod_version_compatibility_note_maps/1/edit
  def edit
  end

  # POST /mod_version_compatibility_note_maps
  # POST /mod_version_compatibility_note_maps.json
  def create
    @mod_version_compatibility_note_map = ModVersionCompatibilityNoteMap.new(mod_version_compatibility_note_map_params)

    respond_to do |format|
      if @mod_version_compatibility_note_map.save
        format.html { redirect_to @mod_version_compatibility_note_map, notice: 'Mod version compatibility note map was successfully created.' }
        format.json { render :show, status: :created, location: @mod_version_compatibility_note_map }
      else
        format.html { render :new }
        format.json { render json: @mod_version_compatibility_note_map.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /mod_version_compatibility_note_maps/1
  # PATCH/PUT /mod_version_compatibility_note_maps/1.json
  def update
    respond_to do |format|
      if @mod_version_compatibility_note_map.update(mod_version_compatibility_note_map_params)
        format.html { redirect_to @mod_version_compatibility_note_map, notice: 'Mod version compatibility note map was successfully updated.' }
        format.json { render :show, status: :ok, location: @mod_version_compatibility_note_map }
      else
        format.html { render :edit }
        format.json { render json: @mod_version_compatibility_note_map.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /mod_version_compatibility_note_maps/1
  # DELETE /mod_version_compatibility_note_maps/1.json
  def destroy
    @mod_version_compatibility_note_map.destroy
    respond_to do |format|
      format.html { redirect_to mod_version_compatibility_note_maps_url, notice: 'Mod version compatibility note map was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_mod_version_compatibility_note_map
      @mod_version_compatibility_note_map = ModVersionCompatibilityNoteMap.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def mod_version_compatibility_note_map_params
      params.require(:mod_version_compatibility_note_map).permit(:mod_version_id, :compatibility_note_id)
    end
end
