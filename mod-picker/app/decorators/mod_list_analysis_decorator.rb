class ModListAnalyisDecorator < Decorator
  attr_accessor :mod_list

  def initialize(mod_list)
    @mod_list = mod_list
  end

  def load_order
    @mod_list.mod_list_plugins.includes(:plugin)
  end

  def install_order
    @mod_list.mod_list_mods.utility(false).includes(:mod, :mod_list_mod_options)
  end

  def plugins
    plugin_ids = @mod_list.mod_list_plugins.official(false).pluck(:plugin_id)
    Plugin.where(id: plugin_ids).includes(:mod, :dummy_masters, :overrides, :masters => :master_plugin)
  end

  def method_missing(method_sym, *arguments, &block)
    @mod_list.public_send(method_sym, *arguments)
  end
end