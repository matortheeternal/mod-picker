class AddExtendedOptionsToModLists < ActiveRecord::Migration
  def change
    add_column :mod_lists, :disable_comments, :boolean, default: false, null: false, after: :comments_count
    add_column :mod_lists, :lock_tags, :boolean, default: false, nuill: false, after: :disable_comments
  end
end
