class ModListBuilder
  attr_accessor :mod_list, :target_mod_list

  def initialize(mod_list, target_mod_list)
    @mod_list = mod_list
    @target_mod_list = target_mod_list
  end

  def copy!
    copy_tools
    copy_mods
    copy_plugins
    copy_configs
  end

  def clone!
    copy_properties!
    copy!
  end

  def copy_properties!
    @target_mod_list.game_id = @mod_list.game_id
    @target_mod_list.is_collection = @mod_list.is_collection
    @target_mod_list.name = "#{@mod_list.name} [Clone]"
    @target_mod_list.description = "A cloned Mod List."
    @target_mod_list.save!
  end

  def copy_model(model, label)
    index = @target_mod_list.public_send("#{label}_count")
    index += 1 unless (label == :plugins) && (index == 0)
    model.each { |item|  index += 1 if item.copy_to(@target_mod_list, index) }
  end

  def groups_by_tab(label)
    @mod_list.mod_list_groups.where(tab: ModListGroup.tabs[label])
  end

  def copy_tools
    model = groups_by_tab("tools").to_a
    model.push(*@mod_list.mod_list_mods.utility(true).orphans.to_a)
    model.push(*@mod_list.custom_mods.utility(true).orphans.to_a)
    model.sort! { |x, y| x.index <=> y.index }
    copy_model(model, :tools)
  end

  def copy_mods
    model = groups_by_tab("mods").to_a
    model.push(*@mod_list.mod_list_mods.utility(false).orphans.to_a)
    model.push(*@mod_list.custom_mods.utility(false).orphans.to_a)
    model.sort! { |x, y| x.index <=> y.index }
    copy_model(model, :mods)
  end

  def copy_plugins
    model = groups_by_tab("plugins").to_a
    model.push(*@mod_list.mod_list_plugins.orphans.to_a)
    model.push(*@mod_list.custom_plugins.orphans.to_a)
    model.sort! { |x, y| x.index <=> y.index }
    copy_model(model, :plugins)
  end

  def copy_configs
    model = @mod_list.mod_list_config_files.to_a
    model.push(*@mod_list.custom_config_files.to_a)
    model.each { |item| item.copy_to(@target_mod_list) }
  end
end