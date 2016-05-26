class ModsController < ApplicationController
  before_action :set_mod, only: [:show, :update, :reviews, :compatibility_notes, :install_order_notes, :load_order_notes, :analysis, :destroy]

  # POST /mods
  def index
    @mods = Mod.includes(:authors).accessible_by(current_ability).filter(filtering_params).sort(params[:sort]).paginate(:page => params[:page])
    @count =  Mod.accessible_by(current_ability).filter(filtering_params).sort(params[:sort]).count

    render :json => {
      mods: @mods.as_json({
          :include => mods_include_hash
      }),
      max_entries: @count,
      entries_per_page: Mod.per_page
    }
  end

  # POST /mods/search
  def search
    @mods = Mod.where(hidden: false).filter(search_params).sort({ column: "name", direction: "ASC" }).limit(10)

    render :json => @mods.as_json({
        :only => [:id, :name]
    })
  end

  # GET /mods/1
  def show
    authorize! :read, @mod
    star = ModStar.exists?(:mod_id => @mod.id, :user_id => current_user.id)
    render :json => {
        mod: @mod.show_json,
        star: star
    }
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

  # PATCH/PUT /mods/1/tags
  def update_tags
    # build array of ids for updated tags
    # create new tags
    mod_tags = []
    params[:tags].each do |tag_text|
      tag = Tag.find(game_id: params[:game_id], text: tag_text)
      if tag.nil?
        tag = Tag.new(game_id: params[:game_id], text: tag_text, submitted_by: current_user.id)
        authorize! :create, @new_tag
        if tag.save
          mod_tags.push(tag.id)
        end
      else
        mod_tags.push(tag.id)
      end
    end

    # authorize tag deletions
    @mod.mod_tags.each do |mod_tag|
      if mod_tags.exclude?(mod_tag.tag_id)
        authorize! :destroy, mod_tag
      end
    end

    # update tags
    @mod.tags.destroy_all
    mod_tags.each do |tag_id|
      mod_tag = @mod.mod_tags.new(tag_id: tag_id)
      authorize! :create, mod_tag
      mod_tag.save
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

  # GET /mods/1/reviews
  def reviews
    authorize! :read, @mod
    reviews = @mod.reviews.accessible_by(current_ability).paginate(:page => params[:page])
    helpful_marks = HelpfulMark.where(submitted_by: current_user.id, helpfulable_type: "Review", helpfulable_id: reviews.ids)
    render :json => {
        reviews: reviews,
        helpful_marks: helpful_marks.as_json({:only => [:helpfulable_id, :helpful]})
    }
  end

  # GET /mods/1/compatibility_notes
  def compatibility_notes
    authorize! :read, @mod
    compatibility_notes = @mod.compatibility_notes.accessible_by(current_ability).paginate(:page => params[:page])
    helpful_marks = HelpfulMark.where(submitted_by: current_user.id, helpfulable_type: "CompatibilityNote", helpfulable_id: compatibility_notes.ids)
    render :json => {
        compatibility_notes: compatibility_notes,
        helpful_marks: helpful_marks.as_json({:only => [:helpfulable_id, :helpful]})
    }
  end

  # GET /mods/1/install_order_notes
  def install_order_notes
    authorize! :read, @mod
    install_order_notes = @mod.install_order_notes.accessible_by(current_ability).paginate(:page => params[:page])
    helpful_marks = HelpfulMark.where(submitted_by: current_user.id, helpfulable_type: "InstallOrderNote", helpfulable_id: install_order_notes.ids)
    render :json => {
        install_order_notes: install_order_notes,
        helpful_marks: helpful_marks.as_json({:only => [:helpfulable_id, :helpful]})
    }
  end

  # GET /mods/1/load_order_notes
  def load_order_notes
    authorize! :read, @mod
    if @mod.plugins_count > 0
      load_order_notes = @mod.load_order_notes.accessible_by(current_ability).paginate(:page => params[:page])
      helpful_marks = HelpfulMark.where(submitted_by: current_user.id, helpfulable_type: "LoadOrderNote", helpfulable_id: load_order_notes.ids)
      render :json => {
          load_order_notes: load_order_notes,
          helpful_marks: helpful_marks.as_json({:only => [:helpfulable_id, :helpful]})
      }
    else
      render json: { load_order_notes: [] }
    end
  end

  # GET /mods/1/analysis
  def analysis
    authorize! :read, @mod
    render json: {
        plugins: @mod.plugins.as_json({
            :include => {
                :masters => {
                    :except => [:plugin_id]
                },
                :dummy_masters => {
                    :except => [:plugin_id]
                },
                :overrides => {
                    :except => [:plugin_id]
                },
                :plugin_errors => {
                    :except => [:plugin_id]
                },
                :plugin_record_groups => {
                    :except => [:plugin_id]
                }
            }
        }),
        assets: @mod.asset_files.as_json({:only => [:filepath]})
    }
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
      @mod = Mod.includes(:nexus_infos, :workshop_infos, :lover_infos).find(params[:id])
    end

    # Params we allow searching on
    def search_params
      params[:filters].slice(:search, :game)
    end

    # Includes hash for mods index query
    def mods_include_hash
      hash = { :authors => { :only => [:id, :username] } }
      sources = params[:filters][:sources]
      hash[:nexus_infos] = {:except => [:mod_id]} if sources[:nexus]
      hash[:lover_infos] = {:except => [:mod_id]} if sources[:lab]
      hash[:workshop_infos] = {:except => [:mod_id]} if sources[:workshop]
      hash
    end
    
    # Params we allow filtering on
    def filtering_params
      # construct valid filters array
      valid_filters = [:sources, :search, :game, :released, :updated, :adult, :utility, :categories, :tags, :stars, :reviews, :rating, :compatibility_notes, :install_order_notes, :load_order_notes, :views, :author]
      source_filters = [:views, :author, :posts, :videos, :images, :discussions, :downloads, :favorites, :subscribers, :endorsements, :unique_downloads, :files, :bugs, :articles]
      sources = params[:filters][:sources]

      # filters available for nexus and workshop
      valid_filters.push(:posts, :videos, :images, :discussions) if sources[:nexus] || sources[:workshop] && !sources[:lab]
      # filters available for nexus and lab
      valid_filters.push(:downloads) if sources[:nexus] || sources[:lab] && !sources[:workshop]
      # filters available for lab or workshop
      # TODO: file_size
      valid_filters.push(:favorites) if sources[:lab] || sources[:workshop] && !sources[:nexus]
      # filters available for workshop only
      valid_filters.push(:subscribers) if sources[:workshop] && !sources[:lab] && !sources[:nexus]
      # filters available for nexus only
      valid_filters.push(:endorsements, :unique_downloads, :files, :bugs, :articles) if sources[:nexus] && !sources[:lab] && !sources[:workshop]

      # get hash of permitted filters
      permitted_filters = params[:filters].slice(*valid_filters)

      # pad filters with sources
      permitted_filters.each do |key, value|
        if source_filters.include?(key.to_sym)
          permitted_filters[key][:sources] = sources
        end
      end

      permitted_filters
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def mod_params
      params.require(:mod).permit(:game_id, :name, :aliases, :is_utility, :has_adult_content, :primary_category_id, :secondary_category_id, :released, :nexus_info_id, :lovers_info_id, :workshop_info_id,
         :required_mods_attributes => [:required_id],
         :tag_names => [],
         :asset_paths => [],
         :plugin_dumps => [:filename, :author, :description, :crc_hash, :record_count, :override_count, :file_size,
           :master_plugins => [:filename, :crc_hash],
           :plugin_record_groups_attributes => [:sig, :record_count, :override_count],
           :plugin_errors_attributes => [:signature, :form_id, :group, :path, :name, :data],
           :overrides_attributes => [:fid, :sig]])
    end
end
