class AddIsDlcToMods < ActiveRecord::Migration
  def change
    add_column :mods, :is_dlc, :boolean, default: false
  end
end
