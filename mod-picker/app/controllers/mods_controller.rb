class ModsController < ApplicationController
  before_action :set_mod, only: [:show, :update, :destroy]

  # POST /mods
  def index
    @mods = Mod.includes(:nexus_infos).filter(filtering_params).sort(params[:sort]).paginate(:page => params[:page])
    @count =  Mod.includes(:nexus_infos).filter(filtering_params).sort(params[:sort]).count

    render :json => {
      mods: @mods,
      max_entries: @count,
      entries_per_page: Mod.per_page
    }
  end

  # GET /mods/1
  def show
    authorize! :read, @mod
    render :json => @mod.show_json
  end

  # POST /mods/submit
  def create
    @mod = Mod.new(mod_params)
    @mod.submitted_by = current_user.id
    authorize! :create, @mod

    if @mod.save
      render json: {status: :ok}
    else
      render json: @mod.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /mods/1
  def update
    authorize! :update, @mod
    if @mod.update(mod_params)
      render json: {status: :ok}
    else
      render json: @mod.errors, status: :unprocessable_entity
    end
  end

  # POST /mods/1/star
  def create_star
    @mod_star = ModStar.find_or_initialize_by(mod_id: params[:id], user_id: current_user.id)
    authorize! :create, @mod_star
    if @mod_star.save
      render json: {status: :ok}
    else
      render json: @mod_star.errors, status: :unprocessable_entity
    end
  end

  # DELETE /mods/1/star
  def destroy_star
    @mod_star = ModStar.find_by(mod_id: params[:id], user_id: current_user.id)
    authorize! :destroy, @mod_star
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

  # GET /mods/1/compatibility_notes
  def compatibility_notes
    @compatibility_notes = @mod.compatibility_notes.paginate(:page => params[:page])
    render :json => @compatibility_notes
  end

  # GET /mods/1/install_order_notes
  def install_order_notes
    @install_order_notes = @mod.install_order_notes.paginate(:page => params[:page])
    render :json => @install_order_notes
  end

  # GET /mods/1/load_order_notes
  def load_order_notes
    @load_order_notes = @mod.load_order_notes.paginate(:page => params[:page])
    render :json => @load_order_notes
  end

  # DELETE /mods/1
  def destroy
    authorize! :destroy, @mod
    if @mod.destroy
      render json: {status: :ok}
    else
      render json: @mod.errors, status: :unprocessable_entity
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_mod
      @mod = Mod.joins(:nexus_infos, :workshop_infos, :lover_infos).find(params[:id])
    end
    
    # Params we allow filtering on
    def filtering_params
      params[:filters].slice(:search, :author, :categories, :tags, :adult, :game, :stars, :reviews, :versions, :released, :updated, :endorsements, :tdl, :udl, :views, :posts, :videos, :images, :files, :articles);
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def mod_params
      params.require(:mod).permit(:game_id, :name, :aliases, :is_utility, :has_adult_content, :primary_category_id, :secondary_category_id, :released, :tag_names, :asset_paths, :nexus_info_id, :lovers_info_id, :workshop_info_id, :plugin_dumps => [:filename, :author, :description, :crc_hash, :record_count, :override_count, :file_size, :plugin_record_groups => [:sig, :record_count, :override_count], :plugin_errors => [:signature, :form_id, :type, :path, :name, :data], :overrides => [:fid, :sig]])
    end
end
