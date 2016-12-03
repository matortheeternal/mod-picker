class ModBuilder
  attr_accessor :mod, :current_user, :params, :tag_names, :nexus_info_id, :lover_info_id, :workshop_info_id, :plugin_ids, :curate

  def builder_attributes
    [:tag_names, :nexus_info_id, :lover_info_id, :workshop_info_id, :curate]
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
      @mod = Mod.new
    end
  end

  def errors
    @mod.errors
  end

  def update
    mod.updated_by = @current_user.id
    update!
    true
  rescue Exception => x
    raise x unless mod.errors.present?
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
    swap_mod_list_mods_tools_counts
  end

  def after_update
    update_adult
    update_mod_list_mods
  end

  def save
    mod.assign_attributes(@params)
    mod.submitted_by = @current_user.id
    save!
    true
  rescue Exception => x
    raise x unless mod.errors.present?
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
    validate_sources
    manage_custom_mods
  end

  def after_save
    link_sources
    create_tags
    create_curator
  end

  def set_config_file_game_ids
    if @config_files_attributes
      @config_files_attributes.each do |config_file|
        config_file[:game_id] = mod.game_id
      end
    end
  end

  def new_sources_present
    @nexus_info_id.present? || @lover_info_id.present? || @workshop_info_id.present? || @params.has_key?(:custom_sources_attributes)
  end

  def old_sources_present
    mod.nexus_infos.present? || mod.lover_infos.present? || mod.workshop_infos.present? || mod.custom_sources.present?
  end

  def validate_sources
    unless new_sources_present || old_sources_present
      errors.add(:sources, "mods must have at least one source")
      raise ActiveRecord::RecordInvalid
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

  def find_new_plugin(new_plugin_records, old_plugin)
    new_plugin_records.detect{|new_plugin|
      new_plugin.filename == old_plugin.filename
    }
  end

  def update_mod_list_mods
    if mod.previous_changes.has_key?(:is_utility)
      mod.mod_list_mods.includes(:mod_list).each do |mod_list_mod|
        mod_list_mod.group_id = nil
        mod_list_mod.is_utility = mod.is_utility
        mod_list_mod.get_index
        mod_list_mod.save!
      end
    end
  end

  def update_adult
    if resource.previous_changes.has_key?(:has_adult_content)
      resource.reviews.update_all(:has_adult_content => resource.has_adult_content)
      resource.corrections.update_all(:has_adult_content => resource.has_adult_content)
      ModList.update_adult(resource.mod_lists.ids)
      CompatibilityNote.update_adult(resource.compatibility_notes.ids)
      InstallOrderNote.update_adult(resource.install_order_notes.ids)
      LoadOrderNote.update_adult(resource.load_order_notes.ids)
    end
  end

  def link_sources
    link_source(@nexus_info_id, NexusInfo)
    link_source(@lover_info_id, LoverInfo)
    link_source(@workshop_info_id, WorkshopInfo)
  end

  def link_source(info_id, model)
    if info_id
      info = model.find(info_id)
      info.mod_id = mod.id
      info.link_uploader
      info.save!
    end
  end

  def create_tags
    if @tag_names
      @tag_names.each do |text|
        tag = Tag.find_by(text: text, game_id: mod.game_id)

        # create tag if we couldn't find it
        if tag.nil?
          tag = Tag.create!({
              text: text,
              game_id: mod.game_id,
              submitted_by: @current_user.id
          })
        end

        # associate tag with mod
        ModTag.create!({
            mod_id: mod.id,
            tag_id: tag.id,
            submitted_by: @current_user.id
        })
      end
    end
  end

  def create_curator
    if @curate
      ModAuthor.create!({
          mod_id: mod.id,
          user_id: @current_user.id,
          role: 2
      })
    end
  end

  def swap_mod_list_mods_tools_counts
    if mod.attribute_changed?(:is_utility)
      tools_operator = mod.is_utility ? "+" : "-"
      mods_operator = mod.is_utility ? "-" : "+"
      mod_list_ids = mod.mod_lists.ids
      ModList.where(id: mod_list_ids).update_all("tools_count = tools_count #{tools_operator} 1, mods_count = mods_count #{mods_operator} 1")
    end
  end

  def substitute_custom_mods
    mod.sources_array.each do |source|
      ModListCustomMod.substitute_for_url(source.url, mod)
    end
  end

  def make_custom_mods
    mod.mod_list_mods.find_each do |mod_list_mod|
      ModListCustomMod.create_from_mod_list_mod(mod_list_mod)
      mod_list_mod.destroy
    end
  end

  def manage_custom_mods
    if mod.was_visible != mod.visible
      mod.visible ? substitute_custom_mods : make_custom_mods
    end
  end

  def self.model_name
    'Mod'
  end
end