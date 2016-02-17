class AddModListCounterCacheColumns < ActiveRecord::Migration
  def change
    add_column :mod_lists, :comments_count, :integer
    add_column :mod_lists, :mods_count, :integer
    add_column :mod_lists, :plugins_count, :integer
    add_column :mod_lists, :custom_plugins_count, :integer
    add_column :mod_lists, :compatibility_notes_count, :integer
    add_column :mod_lists, :installation_notes_count, :integer
    add_column :mod_lists, :user_stars_count, :integer
  end
end
