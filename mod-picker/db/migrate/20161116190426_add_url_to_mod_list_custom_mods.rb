class AddUrlToModListCustomMods < ActiveRecord::Migration
  def change
    add_column :mod_list_custom_mods, :url, :string, after: :name
  end
end
