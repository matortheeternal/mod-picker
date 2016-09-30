class ModBuilder
  attr_accessor :mod, :current_user, :params, :tag_names, :nexus_info_id, :lover_info_id, :workshop_info_id

  def builder_attributes
    [:tag_names, :nexus_info_id, :lover_info_id, :workshop_info_id]
  end

  def initialize(current_user, params={})
    @current_user = current_user
    @params = params.except(*builder_attributes)
    builder_attributes.each do |attribute|
      send(:"#{attribute}=", params[attribute]) if params.has_key?(attribute)
    end
  end

  def mod
    if @mod.present?
      @mod
    elsif @params && @params[:id]
      @mod = Mod.find_or_initialize_by(id: @params[:id])
    else
      @mod = Mod.new(@params)
    end
  end

  def errors
    @mod.errors
  end

  def update
    update!
    true
  rescue
    false
  end

  def update!
    ActiveRecord::Base.transaction do
      mod.attributes = @params
      self.before_save
      self.before_update
      mod.save!
      self.after_update
      self.after_save
    end
  end

  def before_update
    hide_contributions
  end

  def after_update
    update_adult
  end

  def save
    mod.assign_attributes(@params)
    mod.submitted_by = @current_user.id
    save!
    true
  rescue
    false
  end

  def save!
    ActiveRecord::Base.transaction do
      self.before_save
      mod.save!
      self.after_save
    end
  end

  def before_save
    set_config_file_game_ids
  end

  def after_save
    link_sources
    create_tags
  end

  def set_config_file_game_ids
    if @config_files_attributes
      @config_files_attributes.each do |config_file|
        config_file[:game_id] = mod.game_id
      end
    end
  end

  def hide_contributions
    if mod.attribute_changed?(:hidden) && mod.hidden
      # prepare some helper variables
      plugin_ids = mod.plugins.ids
      cnote_ids = mod.compatibility_notes.ids
      inote_ids = mod.install_order_notes.ids
      lnote_ids = mod.load_order_notes.ids

      # hide content
      mod.mod_list_mods.destroy_all
      mod.reviews.update_all(:hidden => true)
      mod.corrections.update_all(:hidden => true)
      mod.compatibility_notes.update_all(:hidden => true)
      mod.install_order_notes.update_all(:hidden => true)
      mod.load_order_notes.update_all(:hidden => true)
      Correction.correctables("CompatibilityNote", cnote_ids).update_all(:hidden => true)
      Correction.correctables("InstallOrderNote", inote_ids).update_all(:hidden => true)
      Correction.correctables("LoadOrderNote", lnote_ids).update_all(:hidden => true)
    elsif mod.attribute_changed?(:disable_reviews) && mod.disable_reviews
      mod.reviews.update_all(:hidden => true)
    end
  end

  def update_adult
    if mod.previous_changes.has_key?(:has_adult_content)
      # prepare some helper variables
      review_ids = mod.reviews.ids
      cnote_ids = mod.compatibility_notes.ids
      inote_ids = mod.install_order_notes.ids
      lnote_ids = mod.load_order_notes.ids
      mod_list_ids = mod.mod_lists.ids

      # propagate has_adult_content to associations
      mod.reviews.update_all(:has_adult_content => mod.has_adult_content)
      mod.corrections.update_all(:has_adult_content => mod.has_adult_content)
      ModList.update_adult(mod_list_ids)
      CompatibilityNote.update_adult(cnote_ids)
      InstallOrderNote.update_adult(inote_ids)
      LoadOrderNote.update_adult(lnote_ids)
      Correction.update_adult(CompatibilityNote, cnote_ids)
      Correction.update_adult(InstallOrderNote, inote_ids)
      Correction.update_adult(LoadOrderNote, lnote_ids)
    end
  end

  def link_sources
    link_source(@nexus_info_id, NexusInfo)
    link_source(@lover_info_id, LoverInfo)
    link_source(@workshop_info_id, WorkshopInfo)
  end

  def link_source(info_id, model)
    if info_id
      info = NexusInfo.find(info_id)
      info.mod_id = mod.id
      info.save!
    end
  end

  def create_tags
    if @tag_names
      @tag_names.each do |text|
        tag = Tag.find_by(text: text, game_id: game_id)

        # create tag if we couldn't find it
        if tag.nil?
          tag = Tag.create(text: text, game_id: game_id, submitted_by: submitted_by)
        end

        # associate tag with mod
        mod.mod_tags.create(tag_id: tag.id, submitted_by: submitted_by)
      end
    end
  end

  def swap_mod_list_mods_tools_counts
    if mod.attribute_changed?(:is_utility)
      tools_operator = mod.is_utility ? "+" : "-"
      mods_operator = mod.is_utility ? "-" : "+"
      mod_list_ids = mod_lists.ids
      ModList.where(id: mod_list_ids).update_all("tools_count = tools_count #{tools_operator} 1, mods_count = mods_count #{mods_operator} 1")
    end
  end

  def self.model_name
    'Mod'
  end
end