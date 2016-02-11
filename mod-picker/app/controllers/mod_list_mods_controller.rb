class ModListModsController < ApplicationController
  before_action :set_mod_list_mod, only: [:show, :edit, :update, :destroy]

  # GET /mod_list_mods
  # GET /mod_list_mods.json
  def index
    @mod_list_mods = ModListMod.all

    respond_to do |format|
      format.html
      format.json { render :json => @mod_list_mods}
    end
  end

  # GET /mod_list_mods/1
  # GET /mod_list_mods/1.json
  def show
    respond_to do |format|
      format.html
      format.json { render :json => @mod_list_mod}
    end
  end

  # GET /mod_list_mods/new
  def new
    @mod_list_mod = ModListMod.new
  end

  # GET /mod_list_mods/1/edit
  def edit
  end

  # POST /mod_list_mods
  # POST /mod_list_mods.json
  def create
    @mod_list_mod = ModListMod.new(mod_list_mod_params)

    respond_to do |format|
      if @mod_list_mod.save
        format.html { redirect_to @mod_list_mod, notice: 'Mod list mod was successfully created.' }
        format.json { render :show, status: :created, location: @mod_list_mod }
      else
        format.html { render :new }
        format.json { render json: @mod_list_mod.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /mod_list_mods/1
  # PATCH/PUT /mod_list_mods/1.json
  def update
    respond_to do |format|
      if @mod_list_mod.update(mod_list_mod_params)
        format.html { redirect_to @mod_list_mod, notice: 'Mod list mod was successfully updated.' }
        format.json { render :show, status: :ok, location: @mod_list_mod }
      else
        format.html { render :edit }
        format.json { render json: @mod_list_mod.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /mod_list_mods/1
  # DELETE /mod_list_mods/1.json
  def destroy
    @mod_list_mod.destroy
    respond_to do |format|
      format.html { redirect_to mod_list_mods_url, notice: 'Mod list mod was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_mod_list_mod
      @mod_list_mod = ModListMod.find_by(mod_list_id: params[:mod_list_id], mod_id: params[:mod_id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def mod_list_mod_params
      params.require(:mod_list_mod).permit(:mod_list_id, :mod_id, :active, :install_order)
    end
end
