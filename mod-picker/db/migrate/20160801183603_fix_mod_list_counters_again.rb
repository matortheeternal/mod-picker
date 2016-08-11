class FixModListCountersAgain < ActiveRecord::Migration
  def change
    rename_column :mod_lists, :active_plugins_count, :available_plugins_count
    add_column :mod_lists, :custom_mods_count, :integer, default: 0, null: false, after: :available_plugins_count

    # we're also going to add a column we forgot to add in the add_mod_list_custom_mods migration
    add_column :mod_list_custom_mods, :is_utility, :boolean, default: false, null: false, after: :index
  end
end
