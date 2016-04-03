class FixModTagsAndModListTags < ActiveRecord::Migration
  def change
    remove_foreign_key :mod_tags, :games
    remove_column :mod_tags, :game_id
    change_column :mod_tags, :tag, :integer, null: false
    rename_column :mod_tags, :tag, :tag_id
    add_foreign_key :mod_tags, :tags

    remove_foreign_key :mod_list_tags, :games
    remove_column :mod_list_tags, :game_id
    change_column :mod_list_tags, :tag, :integer, null: false
    rename_column :mod_list_tags, :tag, :tag_id
    add_foreign_key :mod_list_tags, :tags
  end
end
