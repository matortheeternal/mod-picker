class AddIsOfficialToMods < ActiveRecord::Migration
  def change
    add_column :mods, :is_official, :boolean, default: false
  end
end
