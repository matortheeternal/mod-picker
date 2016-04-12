class ModListModsController < ApplicationController
  before_action :set_mod_list_mod, only: [:update, :destroy]

  # POST /mod_list_mods
  # POST /mod_list_mods.json
  def create
    @mod_list_mod = ModListMod.new(mod_list_mod_params)

    respond_to do |format|
      if @mod_list_mod.save
        format.json { render :show, status: :created, location: @mod_list_mod }
      else
        format.json { render json: @mod_list_mod.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /mod_list_mods/1
  # PATCH/PUT /mod_list_mods/1.json
  def update
    respond_to do |format|
      if @mod_list_mod.update(mod_list_mod_params)
        format.json { render :show, status: :ok, location: @mod_list_mod }
      else
        format.json { render json: @mod_list_mod.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /mod_list_mods/1
  # DELETE /mod_list_mods/1.json
  def destroy
    @mod_list_mod.destroy
    respond_to do |format|
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
