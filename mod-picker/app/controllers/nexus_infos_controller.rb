class NexusInfosController < ApplicationController
  before_action :set_nexus_info, only: [:show, :edit, :update, :destroy]

  # GET /nexus_infos
  # GET /nexus_infos.json
  def index
    @nexus_infos = NexusInfo.all

    respond_to do |format|
      format.html
      format.json { render :json => @nexus_infos}
    end
  end

  # GET /nexus_infos/1
  # GET /nexus_infos/1.json
  def show
    respond_to do |format|
      format.html
      format.json { render :json => @nexus_info}
    end
  end

  # GET /nexus_infos/new
  def new
    @nexus_info = NexusInfo.new
  end

  # GET /nexus_infos/1/edit
  def edit
  end

  # POST /nexus_infos
  # POST /nexus_infos.json
  def create
    @nexus_info = NexusInfo.new(nexus_info_params)

    respond_to do |format|
      if @nexus_info.save
        format.html { redirect_to @nexus_info, notice: 'Nexus info was successfully created.' }
        format.json { render :show, status: :created, location: @nexus_info }
      else
        format.html { render :new }
        format.json { render json: @nexus_info.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /nexus_infos/1
  # PATCH/PUT /nexus_infos/1.json
  def update
    respond_to do |format|
      if @nexus_info.update(nexus_info_params)
        format.html { redirect_to @nexus_info, notice: 'Nexus info was successfully updated.' }
        format.json { render :show, status: :ok, location: @nexus_info }
      else
        format.html { render :edit }
        format.json { render json: @nexus_info.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /nexus_infos/1
  # DELETE /nexus_infos/1.json
  def destroy
    @nexus_info.destroy
    respond_to do |format|
      format.html { redirect_to nexus_infos_url, notice: 'Nexus info was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_nexus_info
      @nexus_info = NexusInfo.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def nexus_info_params
      params.require(:id).permit(:mod_id, :game_id, :uploaded_by, :authors, :endorsements, :total_downloads, :unique_downloads, :views, :posts_count, :videos_count, :images_count, :files_count, :articles_count, :nexus_category, :changelog)
    end
end
