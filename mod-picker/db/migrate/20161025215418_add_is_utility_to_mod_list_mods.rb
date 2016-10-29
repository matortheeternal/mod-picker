class AddIsUtilityToModListMods < ActiveRecord::Migration
  def change
    add_column :mod_list_mods, :is_utility, :boolean, default: false, null: false
    ModListMod.joins(:mod).update_all("mod_list_mods.is_utility = mods.is_utility")
    change_column :mod_list_mods, :is_utility, :boolean, default: nil, null: false
  end
end
