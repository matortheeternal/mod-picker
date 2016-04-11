class ModVersionsController < ApplicationController
  before_action :set_mod_version, only: [:update, :destroy]

  # POST /mod_versions
  # POST /mod_versions.json
  def create
    @mod_version = ModVersion.new(mod_version_params)

    respond_to do |format|
      if @mod_version.save
        format.json { render :json => @mod_version}
      else
        format.json { render json: @mod_version.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /mod_versions/1
  # PATCH/PUT /mod_versions/1.json
  def update
    respond_to do |format|
      if @mod_version.update(mod_version_params)
        format.json { render :json => @mod_version}
      else
        format.json { render json: @mod_version.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /mod_versions/1
  # DELETE /mod_versions/1.json
  def destroy
    @mod_version.destroy
    respond_to do |format|
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
      params.require(:mod_version).permit(:mod_id, :nxm_file_id, :released, :obsolete, :dangerous, :version)
    end
end
