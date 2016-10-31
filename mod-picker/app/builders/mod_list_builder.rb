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
end