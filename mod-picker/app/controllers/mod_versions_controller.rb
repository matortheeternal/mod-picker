class ModVersionsController < ApplicationController
  before_action :set_mod_version, only: [:show, :edit, :update, :destroy]

  # GET /mod_versions
  # GET /mod_versions.json
  def index
    @mod_versions = ModVersion.all
  end

  # GET /mod_versions/1
  # GET /mod_versions/1.json
  def show
  end

  # GET /mod_versions/new
  def new
    @mod_version = ModVersion.new
  end

  # GET /mod_versions/1/edit
  def edit
  end

  # POST /mod_versions
  # POST /mod_versions.json
  def create
    @mod_version = ModVersion.new(mod_version_params)

    respond_to do |format|
      if @mod_version.save
        format.html { redirect_to @mod_version, notice: 'Mod version was successfully created.' }
        format.json { render :show, status: :created, location: @mod_version }
      else
        format.html { render :new }
        format.json { render json: @mod_version.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /mod_versions/1
  # PATCH/PUT /mod_versions/1.json
  def update
    respond_to do |format|
      if @mod_version.update(mod_version_params)
        format.html { redirect_to @mod_version, notice: 'Mod version was successfully updated.' }
        format.json { render :show, status: :ok, location: @mod_version }
      else
        format.html { render :edit }
        format.json { render json: @mod_version.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /mod_versions/1
  # DELETE /mod_versions/1.json
  def destroy
    @mod_version.destroy
    respond_to do |format|
      format.html { redirect_to mod_versions_url, notice: 'Mod version was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_mod_version
      @mod_version = ModVersion.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def mod_version_params
      params.require(:mod_version).permit(:mv_id, :mod_id, :nxm_file_id, :released, :obsolete, :dangerous)
    end
end
