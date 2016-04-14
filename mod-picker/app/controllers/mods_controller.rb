class ModsController < ApplicationController
  before_action :set_mod, only: [:show, :update, :destroy]

  # GET /mods
  # GET /mods.json
  def index
    @mods = Mod.filter(filtering_params)

    respond_to do |format|
      format.html
      format.json { render :json => @mods}
    end
  end

  # GET /mods/1
  # GET /mods/1.json
  def show
    render @mod.show_json
  end

  # POST /mods
  # POST /mods.json
  def create
    @mod = Mod.new(mod_params)

    respond_to do |format|
      if @mod.save
        format.json { render :json => @mod  }
      else
        format.json { render json: @mod.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /mods/1
  # PATCH/PUT /mods/1.json
  def update
    respond_to do |format|
      if @mod.update(mod_params)
        format.json { render :show, status: :ok, location: @mod }
      else
        format.json { render json: @mod.errors, status: :unprocessable_entity }
      end
    end
  end

  # POST /mods/1/star
  def create_star
    @mod_star = ModStar.find_or_initialize_by(mod_id: params[:id], user_id: current_user.id)
    if @mod_star.save
      render json: {status: :ok}
    else
      render json: @mod_star.errors, status: :unprocessable_entity
    end
  end

  # DELETE /mods/1/star
  def destroy_star
    @mod_star = ModStar.find_by(mod_id: params[:id], user_id: current_user.id)
    if @mod_star.nil?
      render json: {status: :ok}
    else
      if @mod_star.delete
        render json: {status: :ok}
      else
        render json: @mod_star.errors, status: :unprocessable_entity
      end
    end
  end

  # DELETE /mods/1
  # DELETE /mods/1.json
  def destroy
    @mod.destroy
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_mod
      @mod = Mod.joins(:nexus_info, :mod_versions).find(params[:id])
    end
    
    # Params we allow filtering on
    def filtering_params
      params.slice(:search, :adult, :game, :category, :stars, :reviews, :versions, :released, :updated, :endorsements, :tdl, :udl, :views, :posts, :videos, :images, :files, :articles);
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def mod_params
      params.require(:mod).permit(:game_id, :name, :aliases, :is_utility, :has_adult_content, :primary_category_id, :secondary_category_id, mod_versions_attributes: [ :released, :obsolete, :dangerous, :version ])
    end
end
