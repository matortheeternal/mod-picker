class ModVersionFilesController < ApplicationController
  before_action :set_mod_version_file_map, only: [:show, :edit, :update, :destroy]

  # GET /mod_version_files
  # GET /mod_version_files.json
  def index
    @mod_version_file_maps = ModVersionFile.all
  end

  # GET /mod_version_files/1
  # GET /mod_version_files/1.json
  def show
  end

  # GET /mod_version_files/new
  def new
    @mod_version_file_map = ModVersionFile.new
  end

  # GET /mod_version_files/1/edit
  def edit
  end

  # POST /mod_version_files
  # POST /mod_version_files.json
  def create
    @mod_version_file_map = ModVersionFile.new(mod_version_file_map_params)

    respond_to do |format|
      if @mod_version_file_map.save
        format.html { redirect_to @mod_version_file_map, notice: 'Mod version file map was successfully created.' }
        format.json { render :show, status: :created, location: @mod_version_file_map }
      else
        format.html { render :new }
        format.json { render json: @mod_version_file_map.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /mod_version_files/1
  # PATCH/PUT /mod_version_files/1.json
  def update
    respond_to do |format|
      if @mod_version_file_map.update(mod_version_file_map_params)
        format.html { redirect_to @mod_version_file_map, notice: 'Mod version file map was successfully updated.' }
        format.json { render :show, status: :ok, location: @mod_version_file_map }
      else
        format.html { render :edit }
        format.json { render json: @mod_version_file_map.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /mod_version_files/1
  # DELETE /mod_version_files/1.json
  def destroy
    @mod_version_file_map.destroy
    respond_to do |format|
      format.html { redirect_to mod_version_file_maps_url, notice: 'Mod version file map was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_mod_version_file_map
      @mod_version_file_map = ModVersionFile.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def mod_version_file_map_params
      params.require(:mod_version_file_map).permit(:mod_version_id, :mod_asset_file_id)
    end
end
