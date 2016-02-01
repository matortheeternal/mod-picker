class ModVersionFilesController < ApplicationController
  before_action :set_mod_version_file, only: [:show, :edit, :update, :destroy]

  # GET /mod_version_files
  # GET /mod_version_files.json
  def index
    @mod_version_files = ModVersionFile.all

    respond_to do |format|
      format.html
      format.json { render :json => @mod_version_files}
    end
  end

  # GET /mod_version_files/1
  # GET /mod_version_files/1.json
  def show
    respond_to do |format|
      format.html
      format.json { render :json => @mod_version_file}
    end
  end

  # GET /mod_version_files/new
  def new
    @mod_version_file = ModVersionFile.new
  end

  # GET /mod_version_files/1/edit
  def edit
  end

  # POST /mod_version_files
  # POST /mod_version_files.json
  def create
    @mod_version_file = ModVersionFile.new(mod_version_file_params)

    respond_to do |format|
      if @mod_version_file.save
        format.html { redirect_to @mod_version_file, notice: 'Mod version file map was successfully created.' }
        format.json { render :show, status: :created, location: @mod_version_file }
      else
        format.html { render :new }
        format.json { render json: @mod_version_file.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /mod_version_files/1
  # PATCH/PUT /mod_version_files/1.json
  def update
    respond_to do |format|
      if @mod_version_file.update(mod_version_file_params)
        format.html { redirect_to @mod_version_file, notice: 'Mod version file map was successfully updated.' }
        format.json { render :show, status: :ok, location: @mod_version_file }
      else
        format.html { render :edit }
        format.json { render json: @mod_version_file.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /mod_version_files/1
  # DELETE /mod_version_files/1.json
  def destroy
    @mod_version_file.destroy
    respond_to do |format|
      format.html { redirect_to mod_version_files_url, notice: 'Mod version file map was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_mod_version_file
      @mod_version_file = ModVersionFile.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def mod_version_file_params
      params.require(:mod_version_file).permit(:mod_version_id, :mod_asset_file_id)
    end
end
