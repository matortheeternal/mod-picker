class AddUserCounterCacheColumns < ActiveRecord::Migration
  def change
    add_column :users, :comments_count, :integer
    add_column :users, :reviews_count, :integer
    add_column :users, :installation_notes_count, :integer
    add_column :users, :compatibility_notes_count, :integer
    add_column :users, :incorrect_notes_count, :integer
    add_column :users, :agreement_marks_count, :integer
    add_column :users, :mods_count, :integer
    add_column :users, :starred_mods_count, :integer
    add_column :users, :starred_mod_lists_count, :integer
    add_column :users, :profile_comments_count, :integer
  end
end
