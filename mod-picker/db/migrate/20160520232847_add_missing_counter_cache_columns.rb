class AddMissingCounterCacheColumns < ActiveRecord::Migration
  def change
    # Article
    add_column :articles, :comments_count, :integer, default: 0
    # Asset File
    add_column :asset_files, :mod_asset_files_count, :integer, default: 0
    # Base Report
    add_column :base_reports, :reports_count, :integer, default: 0
    # Comment
    add_column :comments, :children_count, :integer, default: 0
    # Compatibility Note
    add_column :compatibility_notes, :history_entries_count, :integer, default: 0
    # Config File
    add_column :config_files, :mod_lists_count, :integer, default: 0
    # Game
    add_column :games, :asset_files_count, :integer, default: 0
    add_column :games, :mods_count, :integer, default: 0
    add_column :games, :nexus_infos_count, :integer, default: 0
    add_column :games, :lover_infos_count, :integer, default: 0
    add_column :games, :workshop_infos_count, :integer, default: 0
    add_column :games, :mod_lists_count, :integer, default: 0
    add_column :games, :config_files_count, :integer, default: 0
    add_column :games, :compatibility_notes_count, :integer, default: 0
    add_column :games, :install_order_notes_count, :integer, default: 0
    add_column :games, :load_order_notes_count, :integer, default: 0
    add_column :games, :reviews_count, :integer, default: 0
    add_column :games, :plugins_count, :integer, default: 0
    # Help Page
    add_column :help_pages, :comments_count, :integer, default: 0
    # Install Order Note
    add_column :install_order_notes, :history_entries_count, :integer, default: 0
    add_column :install_order_notes, :comments_count, :integer, default: 0
    add_column :install_order_notes, :corrections_count, :integer, default: 0
    # Mod
    rename_column :mods, :requirements_count, :required_mods_count
    add_column :mods, :required_by_count, :integer, default: 0
    rename_column :mods, :mod_stars_count, :stars_count
    add_column :mods, :tags_count, :integer, default: 0
    # Mod List
    add_column :mod_lists, :active_plugins_count, :integer, default: 0
    rename_column :mod_lists, :user_stars_count, :stars_count
    add_column :mod_lists, :tags_count, :integer, default: 0
    add_column :mod_lists, :config_files_count, :integer, default: 0
    add_column :mod_lists, :custom_config_files_count, :integer, default: 0
    # Review
    add_column :reviews, :ratings_count, :integer, default: 0
    # User
    rename_column :users, :profile_comments_count, :submitted_comments_count
    add_column :users, :mod_lists_count, :integer, default: 0
    add_column :users, :mod_collections_count, :integer, default: 0
    add_column :users, :helpful_marks_count, :integer, default: 0
    add_column :users, :tags_count, :integer, default: 0
    add_column :users, :mod_tags_count, :integer, default: 0
    add_column :users, :mod_list_tags_count, :integer, default: 0
    add_column :users, :authored_mods_count, :integer, default: 0
    rename_column :users, :mods_count, :submitted_mods_count
    # User Reputation
    add_column :user_reputations, :rep_from_count, :integer, default: 0
    add_column :user_reputations, :rep_to_count, :integer, default: 0
  end
end
