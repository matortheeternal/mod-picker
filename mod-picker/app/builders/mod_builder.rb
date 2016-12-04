class ModBuilder
  attr_accessor :tag_names, :nexus_info_id, :lover_info_id, :workshop_info_id, :plugin_ids, :curate

  # core
  def builder_attributes
    [:tag_names, :nexus_info_id, :lover_info_id, :workshop_info_id, :curate]
  end

  def resource_class
    Mod
  end

  def created_by_key
    "submitted_by"
  end

  # callbacks
  def before_update
    hide_contributions
    swap_mod_list_mods_tools_counts
  end

  def after_update
    update_adult
    update_mod_list_mods
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
        config_file[:game_id] = resource.game_id
      end
    end
  end

  def new_sources_present
    @nexus_info_id.present? || @lover_info_id.present? || @workshop_info_id.present? || @params.has_key?(:custom_sources_attributes)
  end

  def old_sources_present
    resource.nexus_infos.present? || resource.lover_infos.present? || resource.workshop_infos.present? || resource.custom_sources.present?
  end

  def validate_sources
    unless new_sources_present || old_sources_present
      errors.add(:sources, "mods must have at least one source")
      raise ActiveRecord::RecordInvalid
    end
  end

  def hide_contributions
    if resource.attribute_changed?(:hidden) && resource.hidden
      resource.reviews.update_all(:hidden => true)
      resource.corrections.update_all(:hidden => true)
      resource.compatibility_notes.update_all(:hidden => true)
      resource.install_order_notes.update_all(:hidden => true)
      resource.load_order_notes.update_all(:hidden => true)
      Correction.correctables("CompatibilityNote", resource.compatibility_notes.ids).update_all(:hidden => true)
      Correction.correctables("InstallOrderNote", resource.install_order_notes.ids).update_all(:hidden => true)
      Correction.correctables("LoadOrderNote", resource.load_order_notes.ids).update_all(:hidden => true)
    elsif resource.attribute_changed?(:disable_reviews) && resource.disable_reviews
      resource.reviews.update_all(:hidden => true)
    end
  end

  def find_new_plugin(new_plugin_records, old_plugin)
    new_plugin_records.detect{|new_plugin|
      new_plugin.filename == old_plugin.filename
    }
  end

  def update_mod_list_mods
    if resource.previous_changes.has_key?(:is_utility)
      resource.mod_list_mods.includes(:mod_list).each do |mod_list_mod|
        mod_list_mod.group_id = nil
        mod_list_mod.is_utility = resource.is_utility
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
      info.mod_id = resource.id
      info.link_uploader
      info.save!
    end
  end

  def create_tags
    if @tag_names
      TagBuilder.create_tags(resource, @current_user, @tag_names)
    end
  end

  def create_curator
    if @curate
      ModAuthor.create!({
          mod_id: resource.id,
          user_id: @current_user.id,
          role: 2
      })
    end
  end

  def swap_mod_list_mods_tools_counts
    if resource.attribute_changed?(:is_utility)
      tools_operator = resource.is_utility ? "+" : "-"
      mods_operator = resource.is_utility ? "-" : "+"
      mod_list_ids = resource.mod_lists.ids
      ModList.where(id: mod_list_ids).update_all("tools_count = tools_count #{tools_operator} 1, mods_count = mods_count #{mods_operator} 1")
    end
  end

  def substitute_custom_mods
    resource.sources_array.each do |source|
      ModListCustomMod.substitute_for_url(source.url, mod)
    end
  end

  def make_custom_mods
    resource.mod_list_mods.find_each do |mod_list_mod|
      ModListCustomMod.create_from_mod_list_mod(mod_list_mod)
      mod_list_mod.destroy
    end
  end

  def manage_custom_mods
    if resource.was_visible != resource.visible
      resource.visible ? substitute_custom_mods : make_custom_mods
    end
  end
end