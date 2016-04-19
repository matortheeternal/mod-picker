class ModVersionsController < ApplicationController
  before_action :set_mod_version, only: [:compatibility_notes, :load_order_notes, :install_order_notes, :update, :destroy]

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

  # GET /mod_versions/1/compatibility_notes.json
  def compatibility_notes
    @compatibility_notes = @mod_version.compatibility_notes

    render json: @compatibility_notes
  end

  # GET /mod_versions/1/load_order_notes.json
  def load_order_notes
    @load_order_notes = @mod_version.load_order_notes

    render json: @load_order_notes
  end

  # GET /mod_versions/1/install_order_notes.json
  def install_order_notes
    @install_order_notes = @mod_version.install_order_notes

    render json: @install_order_notes
  end

  # PATCH/PUT /mod_versions/1.json
  def update
    authorize! :update, @mod_version
    if @mod_version.update(mod_version_params)
      render json: {status: :ok}
    else
      render json: @mod_version.errors, status: :unprocessable_entity
    end
  end

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
