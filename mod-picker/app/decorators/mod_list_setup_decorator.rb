class ModListSetupDecorator < Decorator
  attr_accessor :mod_list
  attr_accessor :mod_list_mods

  def initialize(mod_list)
    @mod_list = mod_list
    @mod_list_mods = {}
  end

  def plugins
    @mod_list.mod_list_plugins.preload(:plugin).as_json({format: "setup"})
  end

  def custom_plugins
    @mod_list.custom_plugins.as_json({format: "setup"})
  end

  def mod_list_mods(official)
    @mod_list_mods[official.to_s] ||= @mod_list.mod_list_mods.eager_load(:mod).preload(:mod_list_mod_options, mod: [:lover_infos, :workshop_infos, :custom_sources, :mod_options, {nexus_infos: [:game]}]).where(mods: {is_official: official})
  end

  def mods
    mod_list_mods(false).as_json({format: "setup"})
  end

  def custom_mods
    @mod_list.custom_mods.as_json({format: "setup"})
  end

  def official_content
    mod_list_mods(true).as_json({format: "setup_official"})
  end

  def extenders
    mod_list_mods(false).select{|m| m.mod.is_extender}.map{|m| m.id}
  end

  def mod_managers
    mod_list_mods(false).select{|m| m.mod.is_mod_manager}.map{|m| m.id}
  end

  def method_missing(method_sym, *arguments, &block)
    @mod_list.public_send(method_sym, *arguments)
  end
end