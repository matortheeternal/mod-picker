class ModAssetFilesController < ApplicationController
  before_action :set_mod_asset_file, only: [:show, :edit, :update, :destroy]

  # GET /mod_asset_files
  # GET /mod_asset_files.json
  def index
    @mod_asset_files = ModAssetFile.all

    respond_to do |format|
      format.html
      format.json { render :json => @mod_asset_files}
    end
  end

  # GET /mod_asset_files/1
  # GET /mod_asset_files/1.json
  def show
    respond_to do |format|
      format.html
      format.json { render :json => @mod_asset_file}
    end
  end

  # GET /mod_asset_files/new
  def new
    @mod_asset_file = ModAssetFile.new
  end

  # GET /mod_asset_files/1/edit
  def edit
  end

  # POST /mod_asset_files
  # POST /mod_asset_files.json
  def create
    @mod_asset_file = ModAssetFile.new(mod_asset_file_params)

    respond_to do |format|
      if @mod_asset_file.save
        format.json { render :show, status: :created, location: @mod_asset_file }
      else
        format.json { render json: @mod_asset_file.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /mod_asset_files/1
  # PATCH/PUT /mod_asset_files/1.json
  def update
    respond_to do |format|
      if @mod_asset_file.update(mod_asset_file_params)
        format.json { render :show, status: :ok, location: @mod_asset_file }
      else
        format.json { render json: @mod_asset_file.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /mod_asset_files/1
  # DELETE /mod_asset_files/1.json
  def destroy
    @mod_asset_file.destroy
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_mod_asset_file
      @mod_asset_file = ModAssetFile.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def mod_asset_file_params
      params.require(:mod_asset_file).permit(:filepath)
    end
end
