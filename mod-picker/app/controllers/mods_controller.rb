class ModsController < ApplicationController
  before_action :set_mod, only: [:update, :update_tags, :image, :corrections, :reviews, :compatibility_notes, :install_order_notes, :load_order_notes, :analysis, :destroy]

  # POST /mods
  # TODO: Adult content filtering
  def index
    @mods = Mod.includes(:author_users).accessible_by(current_ability).filter(filtering_params).sort(params[:sort]).paginate(:page => params[:page])
    count =  Mod.accessible_by(current_ability).filter(filtering_params).count

    render :json => {
      mods: @mods.as_json({
          :include => mods_include_hash
      }),
      max_entries: count,
      entries_per_page: Mod.per_page
    }
  end

  # POST /mods/search
  def search
    @mods = Mod.hidden(false).is_game(false).filter(search_params).sort({ column: "name", direction: "ASC" }).limit(10)
    render :json => @mods.as_json({
        :only => [:id, :name]
    })
  end

  # GET /mods/1
  def show
    @mod = Mod.includes(:nexus_infos, :workshop_infos, :lover_infos).find(params[:id])
    authorize! :read, @mod
    star = ModStar.exists?(:mod_id => @mod.id, :user_id => current_user.id)
    render :json => {
        mod: @mod.show_json,
        star: star
    }
  end

  # GET /mods/1/edit
  def edit
    @mod = Mod.find(params[:id])
    authorize! :update, @mod
    render :json => @mod.edit_json
  end

  # POST /mods/submit
  def create
    @mod = Mod.new(mod_params)
    @mod.submitted_by = current_user.id
    authorize! :create, @mod
    authorize! :assign_custom_sources, @mod if params[:mod][:custom_sources_attributes]

    if @mod.save
      @mod.update_metrics
      render json: {status: :ok}
    else
      render json: @mod.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /mods/1
  def update
    authorize! :update, @mod
    authorize! :assign_authors, @mod if params[:mod][:mod_authors_attributes]

    # destroy associations as needed
    if params[:mod][:plugin_dumps] || params[:mod][:asset_paths]
      @mod.mod_asset_files.destroy_all
      @mod.plugins.destroy_all
    end

    if @mod.update(mod_update_params)
      @mod.update_metrics
      render json: {status: :ok}
    else
      render json: @mod.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /mods/1/tags
  def update_tags
    # errors array to return to user
    errors = ActiveModel::Errors.new(self)
    current_user_id = current_user.id

    # perform tag deletions
    existing_mod_tags = @mod.mod_tags
    existing_tags_text = @mod.tags.pluck(:text)
    @mod.mod_tags.each_with_index do |mod_tag, index|
      if params[:tags].exclude?(existing_tags_text[index])
        authorize! :destroy, mod_tag
        mod_tag.destroy
      end
    end

    # update tags
    params[:tags].each do |tag_text|
      if existing_tags_text.exclude?(tag_text)
        # find or create tag
        tag = Tag.where(game_id: params[:game_id], text: tag_text).first
        if tag.nil?
          tag = Tag.new(game_id: params[:game_id], text: tag_text, submitted_by: current_user_id)
          authorize! :create, tag
          if !tag.save
            tag.errors.full_messages.each {|msg| errors[:base] << msg}
            next
          end
        end

        # create mod tag
        mod_tag = @mod.mod_tags.new(tag_id: tag.id, submitted_by: current_user_id)
        authorize! :create, mod_tag
        next if mod_tag.save
        mod_tag.errors.full_messages.each {|msg| errors[:base] << msg}
      end
    end

    if errors.empty?
      render json: {status: :ok, tags: @mod.tags}
    else
      render json: {errors: errors, status: :unprocessable_entity, tags: @mod.tags}
    end
  end

  # POST /mods/1/image
  def image
    authorize! :update, @mod
    @mod.image_file = params[:image]

    if @mod.save
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

  # POST/GET /mods/1/corrections
  def corrections
    authorize! :read, @mod
    corrections = @mod.corrections.accessible_by(current_ability)
    agreement_marks = AgreementMark.where(submitted_by: current_user.id, correction_id: corrections.ids)
    render :json => {
        corrections: corrections,
        agreement_marks: agreement_marks
    }
  end

  # POST/GET /mods/1/reviews
  def reviews
    authorize! :read, @mod

    # get reviews
    reviews = @mod.reviews.includes(:review_ratings, :submitter => :reputation).accessible_by(current_ability).sort(params[:sort]).paginate(:page => params[:page], :per_page => 10).where("submitted_by != ? OR hidden = true", current_user.id)
    count = @mod.reviews.accessible_by(current_ability).count
    review_ids = reviews.ids

    # handle user review
    user_review = @mod.reviews.find_by(submitted_by: current_user.id)
    if user_review.present?
      if user_review.hidden
        user_review = {}
      else
        review_ids.push(user_review.id) if user_review.present?
      end
    end

    # get helpful marks
    helpful_marks = HelpfulMark.where(submitted_by: current_user.id, helpfulable_type: "Review", helpfulable_id: review_ids)
    render :json => {
        reviews: reviews,
        helpful_marks: helpful_marks,
        user_review: user_review,
        max_entries: count,
        entries_per_page: 10
    }
  end

  # POST/GET /mods/1/compatibility_notes
  def compatibility_notes
    authorize! :read, @mod
    compatibility_notes = @mod.compatibility_notes.accessible_by(current_ability).sort(params[:sort]).paginate(:page => params[:page], :per_page => 10)
    count =  @mod.compatibility_notes.accessible_by(current_ability).count
    helpful_marks = HelpfulMark.where(submitted_by: current_user.id, helpfulable_type: "CompatibilityNote", helpfulable_id: compatibility_notes.ids)
    render :json => {
        compatibility_notes: compatibility_notes,
        helpful_marks: helpful_marks,
        max_entries: count,
        entries_per_page: 10
    }
  end

  # POST/GET /mods/1/install_order_notes
  def install_order_notes
    authorize! :read, @mod
    install_order_notes = @mod.install_order_notes.accessible_by(current_ability).sort(params[:sort]).paginate(:page => params[:page], :per_page => 10)
    count =  @mod.install_order_notes.accessible_by(current_ability).count
    helpful_marks = HelpfulMark.where(submitted_by: current_user.id, helpfulable_type: "InstallOrderNote", helpfulable_id: install_order_notes.ids)
    render :json => {
        install_order_notes: install_order_notes,
        helpful_marks: helpful_marks,
        max_entries: count,
        entries_per_page: 10
    }
  end

  # POST/GET /mods/1/load_order_notes
  def load_order_notes
    authorize! :read, @mod
    if @mod.plugins_count > 0
      load_order_notes = @mod.load_order_notes.accessible_by(current_ability).sort(params[:sort]).paginate(:page => params[:page], :per_page => 10)
      count =  @mod.load_order_notes.accessible_by(current_ability).count
      helpful_marks = HelpfulMark.where(submitted_by: current_user.id, helpfulable_type: "LoadOrderNote", helpfulable_id: load_order_notes.ids)
      render :json => {
          load_order_notes: load_order_notes,
          helpful_marks: helpful_marks,
          max_entries: count,
          entries_per_page: 10
      }
    else
      render json: { load_order_notes: [] }
    end
  end

  # POST/GET /mods/1/analysis
  def analysis
    authorize! :read, @mod
    render json: {
        plugins: @mod.plugins.as_json({
            :include => {
                :masters => {
                    :except => [:plugin_id],
                    :include => {
                        :master_plugin => {
                            :only => [:filename]
                        }
                    }
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
      @mod = Mod.find(params[:id])
    end

    # Params we allow searching on
    def search_params
      params[:filters].slice(:search, :game)
    end

    # Includes hash for mods index query
    def mods_include_hash
      hash = { :author_users => { :only => [:id, :username] } }
      sources = params[:filters][:sources]
      hash[:nexus_infos] = {:except => [:mod_id]} if sources[:nexus]
      hash[:lover_infos] = {:except => [:mod_id]} if sources[:lab]
      hash[:workshop_infos] = {:except => [:mod_id]} if sources[:workshop]
      hash
    end
    
    # Params we allow filtering on
    def filtering_params
      # construct valid filters array
      valid_filters = [:sources, :search, :game, :released, :updated, :adult, :utility, :categories, :tags, :stars, :reviews, :rating, :reputation, :compatibility_notes, :install_order_notes, :load_order_notes, :views, :author]
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
          unless permitted_filters[key].is_a?(Hash)
            permitted_filters[key] = { :value => permitted_filters[key] }
          end
          permitted_filters[key][:sources] = sources
        end
      end

      permitted_filters
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def mod_params
      params.require(:mod).permit(:game_id, :name, :authors, :aliases, :is_utility, :has_adult_content, :primary_category_id, :secondary_category_id, :released, :updated, :nexus_info_id, :lovers_info_id, :workshop_info_id,
         :custom_sources_attributes => [:label, :url],
         :required_mods_attributes => [:required_id],
         :tag_names => [],
         :asset_paths => [],
         :plugin_dumps => [:filename, :author, :description, :crc_hash, :record_count, :override_count, :file_size,
           :master_plugins => [:filename, :crc_hash],
           :plugin_record_groups_attributes => [:sig, :record_count, :override_count],
           :plugin_errors_attributes => [:signature, :form_id, :group, :path, :name, :data],
           :overrides_attributes => [:fid, :sig]])
    end

    def mod_update_params
      params.require(:mod).permit(:name, :authors, :aliases, :is_utility, :has_adult_content, :primary_category_id, :secondary_category_id, :released, :updated, :nexus_info_id, :lovers_info_id, :workshop_info_id,
         :required_mods_attributes => [:id, :required_id, :_destroy],
         :mod_authors_attributes => [:id, :role, :user_id, :_destroy],
         :custom_sources_attributes => [:id, :label, :url, :_destroy],
         :tag_names => [],
         :asset_paths => [],
         :plugin_dumps => [:filename, :author, :description, :crc_hash, :record_count, :override_count, :file_size,
           :master_plugins => [:filename, :crc_hash],
           :plugin_record_groups_attributes => [:sig, :record_count, :override_count],
           :plugin_errors_attributes => [:signature, :form_id, :group, :path, :name, :data],
           :overrides_attributes => [:fid, :sig]])
    end
end
