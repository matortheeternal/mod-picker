class ModListSetupDecorator < Decorator
  attr_accessor :mod_list
  attr_accessor :mod_list_mods

  def initialize(mod_list)
    @mod_list = mod_list
    @mod_list_mods = {}
  end

  def load_mod_list_mods
    @mod_list.mod_list_mods.eager_load(:mod).preload(:mod_list_mod_options, mod: [:lover_infos, :workshop_infos, :custom_sources, :mod_options, {nexus_infos: [:game]}]).order(:index)
  end

  def mod_list_mods(is_utility, is_official=nil)
    if is_official.nil?
      load_mod_list_mods.where(is_utility: is_utility)
    else
      load_mod_list_mods.where(is_utility: is_utility, mods: {is_official: is_official})
    end
  end

  def mod_list_custom_mods(is_utility)
    @mod_list.custom_mods.where(is_utility: is_utility).order(:index)
  end

  def tools
    mod_list_mods(true).as_json({format: "setup_tools"})
  end

  def mods
    mod_list_mods(false, false).as_json({format: "setup"})
  end

  def plugins
    @mod_list.mod_list_plugins.preload(:plugin).order(:index).as_json({format: "setup"})
  end

  def config_files
    @mod_list.mod_list_config_files.preload(:config_file).as_json({format: "setup"})
  end

  def custom_tools
    mod_list_custom_mods(true).as_json({format: "setup"})
  end

  def custom_mods
    mod_list_custom_mods(false).as_json({format: "setup"})
  end

  def custom_plugins
    @mod_list.custom_plugins.order(:index).as_json({format: "setup"})
  end

  def custom_config_files
    @mod_list.custom_config_files.as_json({format: "setup"})
  end

  def official_content
    mod_list_mods(false, true).as_json({format: "setup_official"})
  end

  def method_missing(method_sym, *arguments, &block)
    @mod_list.public_send(method_sym, *arguments)
  end
end