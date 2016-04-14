class SetCounterCacheDefaults < ActiveRecord::Migration
  def change
    # users
    change_column :users, :comments_count, :integer, default: 0
    change_column :users, :reviews_count, :integer, default: 0
    change_column :users, :install_order_notes_count, :integer, default: 0
    change_column :users, :compatibility_notes_count, :integer, default: 0
    change_column :users, :incorrect_notes_count, :integer, default: 0
    change_column :users, :agreement_marks_count, :integer, default: 0
    change_column :users, :mods_count, :integer, default: 0
    change_column :users, :starred_mods_count, :integer, default: 0
    change_column :users, :starred_mod_lists_count, :integer, default: 0
    change_column :users, :profile_comments_count, :integer, default: 0
    change_column :users, :mod_stars_count, :integer, default: 0
    change_column :users, :load_order_notes_count, :integer, default: 0

    # reviews
    change_column :reviews, :incorrect_notes_count, :integer, default: 0

    # mods
    change_column :mods, :mod_stars_count, :integer, default: 0
    change_column :mods, :reviews_count, :integer, default: 0
    change_column :mods, :mod_versions_count, :integer, default: 0
    change_column :mods, :compatibility_notes_count, :integer, default: 0
    change_column :mods, :install_order_notes_count, :integer, default: 0
    change_column :mods, :load_order_notes_count, :integer, default: 0

    # mod lists
    change_column :mod_lists, :comments_count, :integer, default: 0
    change_column :mod_lists, :mods_count, :integer, default: 0
    change_column :mod_lists, :plugins_count, :integer, default: 0
    change_column :mod_lists, :custom_plugins_count, :integer, default: 0
    change_column :mod_lists, :compatibility_notes_count, :integer, default: 0
    change_column :mod_lists, :install_order_notes_count, :integer, default: 0
    change_column :mod_lists, :user_stars_count, :integer, default: 0
    change_column :mod_lists, :load_order_notes_count, :integer, default: 0

    # compatibility notes
    change_column :compatibility_notes, :incorrect_notes_count, :integer, default: 0
  end
end
