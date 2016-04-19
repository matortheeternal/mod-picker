class ModVersionsController < ApplicationController
  before_action :set_mod_version, only: [:update, :destroy]

  # POST /mod_versions
  # POST /mod_versions.json
  def create
    @mod_version = ModVersion.new(mod_version_params)
    authorize! :create, @mod_version

    if @mod_version.save
      render json: {status: :ok}
    else
      render json: @mod_version.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /mod_versions/1
  # PATCH/PUT /mod_versions/1.json
  def update
    authorize! :update, @mod_version
    if @mod_version.update(mod_version_params)
      render json: {status: :ok}
    else
      render json: @mod_version.errors, status: :unprocessable_entity
    end
  end

  # DELETE /mod_versions/1
  # DELETE /mod_versions/1.json
  def destroy
    authorize! :destroy, @mod_version
    if @mod_version.destroy
      render json: {status: :ok}
    else
      render json: @mod_version.errors, status: :unprocessable_entity
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
