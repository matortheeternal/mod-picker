class MakeIsUtilityColumnsDefaultFalse < ActiveRecord::Migration
  def change
    change_column :mod_list_mods, :is_utility, :boolean, default: false, null: false
    change_column :mod_list_custom_mods, :is_utility, :boolean, default: false, null: false
  end
end
