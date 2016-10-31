class ModListBuilder
  def initialize(mod_list, other_mod_list)
    @mod_list = mod_list
    @other_mod_list = other_mod_list
  end

  def copy
    copy_tools
    copy_mods
    copy_plugins
    copy_configs
  end

  def clone
    copy_properties
    copy
  end

  def copy_properties
    @other_mod_list.game_id = @mod_list.game_id
    @other_mod_list.is_collection = @mod_list.is_collection
    @other_mod_list.name = "#{@mod_list.name} [Clone]"
    @other_mod_list.description = "A cloned Mod List."
  end

  def copy_model(model, label)
    index = @other_mod_list.public_send("#{label}_count") + 1
    model.each do |item|
      item.copy_to(@other_mod_list)
      index += 1
    end
  end

  def groups_by_tab(label)
    @mod_list.mod_list_groups.where(tab: ModListGroup.tabs[label])
  end

  def copy_tools
    model = groups_by_tab("tools").to_a
    model.push(*@mod_list.mod_list_mods.utility(true).orphans.to_a)
    model.push(*@mod_list.custom_mods.utility(true).orphans.to_a)
    model.sort { |x, y| x.index <=> y.index }
    copy_model(model, :tools)
  end

  def copy_mods
    model = groups_by_tab("mods").to_a
    model.push(*@mod_list.mod_list_mods.utility(false).orphans.to_a)
    model.push(*@mod_list.custom_mods.utility(false).orphans.to_a)
    model.sort { |x, y| x.index <=> y.index }
    copy_model(model, :mods)
  end

  def copy_plugins
    model = groups_by_tab("plugins").to_a
    model.push(*@mod_list.mod_list_plugins.orphans.to_a)
    model.push(*@mod_list.custom_plugins.orphans.to_a)
    model.sort { |x, y| x.index <=> y.index }
    copy_model(model, :plugins)
  end

  def copy_configs
    model = @mod_list.mod_list_config_files.to_a
    model.push(*@mod_list.custom_config_files.to_a)
    model.each { |item| item.copy_to(@other_mod_list) }
  end
end