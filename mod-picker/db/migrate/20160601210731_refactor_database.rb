class RefactorDatabase < ActiveRecord::Migration
  # This migration reorders columns on tables primarily
  # The migration also sets default values where missing and null: false on certain column

  def change
    # agreement_marks
    change_table "agreement_marks" do |t|
      t.change :correction_id, :integer, null: false
      t.change :submitted_by, :integer, null: false
      t.change :agree, :boolean, default: true, null: false
    end

    # articles
    change_table "articles" do |t|
      t.change :game_id, :integer, null: false, after: :id
      t.change :title, :string, null: false, after: :submitted_by
      t.change :comments_count, :integer, default: 0, null: false, after: :text_body
      t.change :edited, :datetime, null: true, after: :submitted
    end

    # asset_files
    change_table "asset_files" do |t|
      t.change :game_id, :integer, null: false, after: :id
      t.change :mod_asset_files_count, :integer, default: 0, null: false
    end

    # base_reports
    change_table "base_reports" do |t|
      t.change :reports_count, :integer, default: 0, null: false, after: :reportable_type
      t.change :edited, :datetime, null: true, after: :submitted
    end

    # categories
    change_table "categories" do |t|
      t.change :name, :string, limit: 64, null: false
      t.change :description, :string, limit: 255, null: false
    end

    # category_priorities
    change_table "category_priorities" do |t|
      t.change :dominant_id, :integer, null: false
      t.change :recessive_id, :integer, null: false
      t.change :description, :string, null: false
    end

    # comments
    change_table "comments" do |t|
      t.change :parent_id, :integer
      t.change :submitted_by, :integer, null: false
      t.change :commentable_id, :integer, null: false, after: :submitted_by
      t.change :commentable_type, :string, null: false, after: :commentable_id
      t.change :text_body, :text, null: false, after: :commentable_type
      t.change :children_count, :integer, default: 0, null: false, after: :text_body
      t.change :hidden, :boolean, default: false, null: false, after: :children_count
      t.change :submitted, :datetime, null: false, after: :hidden
      t.change :edited, :datetime, after: :submitted
    end

    # compatibility_note_history_entries
    change_table "compatibility_note_history_entries" do |t|
      t.change :submitted_by, :integer, null: false, after: :compatibility_note_id
      t.rename :compatibility_type, :status
      t.change :status, :integer, null: false, after: :submitted_by
      t.change :text_body, :text, null: false, after: :compatibility_plugin_id
      t.change :edit_summary, :text, null: true, after: :text_body
      t.change :submitted, :datetime, null: false
      t.change :edited, :datetime
    end

    # compatibility_notes
    change_table "compatibility_notes" do |t|
      t.change :game_id, :integer, null: false, after: :id
      t.change :submitted_by, :integer, null: false, after: :game_id
      t.rename :compatibility_type, :status
      t.change :status, :integer, null: false, after: :submitted_by
      t.change :first_mod_id, :integer, null: false, after: :status
      t.change :second_mod_id, :integer, null: false, after: :status
      t.change :compatibility_mod_id, :integer, after: :second_mod_id
      t.change :compatibility_plugin_id, :integer, after: :compatibility_mod_id
      t.change :text_body, :text, null: false, after: :compatibility_plugin_id
      t.column :edit_summary, :string, after: :text_body
      t.change :moderator_message, :string, after: :edit_summary
      t.change :helpful_count, :integer, default: 0, null: false, after: :moderator_message
      t.change :not_helpful_count, :integer, default: 0, null: false, after: :helpful_count
      t.change :corrections_count, :integer, default: 0, null: false, after: :not_helpful_count
      t.change :history_entries_count, :integer, default: 0, null: false, after: :corrections_count
      t.change :approved, :boolean, default: false, null: false, after: :history_entries_count
      t.change :hidden, :boolean, default: false, null: false, after: :approved
      t.change :submitted, :datetime,  null: false, after: :hidden
      t.change :edited, :datetime, after: :approved
    end

    # config_files
    change_table "config_files" do |t|
      t.rename :default_text_body, :text_body
      t.change :mod_lists_count, :integer, default: 0, null: false
    end

    # corrections
    change_table "corrections" do |t|
      t.change :game_id, :integer, null: false, after: :id
      t.change :correctable_id, :integer, null: false, after: :game_id
      t.change :correctable_type, :string, null: false, after: :correctable_id
      t.change :title, :string, limit: 64, null: false, after: :correctable_type
      t.change :text_body, :text, null: false, after: :title
      t.change :status, :integer, default: 0, null: false, after: :text_body
      t.change :agree_count, :integer, default: 0, null: false, after: :status
      t.change :disagree_count, :integer, default: 0, null: false, after: :agree_count
      t.change :comments_count, :integer, default: 0, null: false, after: :disagree_count
      t.change :hidden, :boolean, default: false, null: false, after: :comments_count
      t.change :submitted, :datetime, null: false, after: :hidden
      t.change :edited, :datetime, null: true, after: :submitted
    end

    # dummy masters
    change_table "dummy_masters" do |t|
      t.change :plugin_id, :integer, null: false
      t.change :index, :integer, null: false, after: :plugin_id
      t.change :filename, :string, null: false, after: :index
    end

    # games
    change_table "games" do |t|
      t.change :display_name, :string, limit: 32, null: false
      t.change :nexus_name, :string, limit: 16, null: false, after: :display_name
      t.change :long_name, :string, limit: 128, null: false
      t.change :abbr_name, :string, limit: 32, null: false
      t.change :exe_name, :string, limit: 32, null: false
      t.change :steam_app_ids, :string, limit: 64, null: false
      t.change :mods_count, :integer, default: 0, null: false, after: :steam_app_ids
      t.change :plugins_count, :integer, default: 0, null: false, after: :mods_count
      t.change :asset_files_count, :integer, default: 0, null: false, after: :plugins_count
      t.change :nexus_infos_count, :integer, default: 0, null: false, after: :asset_files_count
      t.change :lover_infos_count, :integer, default: 0, null: false, after: :nexus_infos_count
      t.change :workshop_infos_count, :integer, default: 0, null: false, after: :lover_infos_count
      t.change :mod_lists_count, :integer, default: 0, null: false, after: :workshop_infos_count
      t.change :config_files_count, :integer, default: 0, null: false, after: :mod_lists_count
      t.change :reviews_count, :integer, default: 0, null: false, after: :config_files_count
      t.change :compatibility_notes_count, :integer, default: 0, null: false, after: :reviews_count
      t.change :install_order_notes_count, :integer, default: 0, null: false, after: :compatibility_notes_count
      t.change :load_order_notes_count, :integer, default: 0, null: false, after: :install_order_notes_count
      t.change :corrections_count, :integer, default: 0, null: false, after: :load_order_notes_count
    end

    # help pages
    change_table "help_pages" do |t|
      t.change :text_body, :text, null: false, after: :name
      t.change :comments_count, :integer, default: 0, null: false, after: :text_body
      t.change :submitted, :datetime, null: false, after: :comments_count
      t.change :edited, :datetime, after: :submitted
    end

    # helpful marks
    HelpfulMark.where(:submitted => nil).update_all(:submitted => DateTime.now)
    change_table "helpful_marks" do |t|
      t.change :submitted_by, :integer, null: false
      t.change :helpfulable_id, :integer, null: false, after: :submitted_by
      t.change :helpfulable_type, :string, null: false, after: :helpfulable_id
      t.change :helpful, :boolean, default: true, null: false, after: :helpfulable_type
      t.change :submitted, :datetime, null: false, after: :helpful
    end

    # install order note history entries
    change_table "install_order_note_history_entries" do |t|
      t.change :install_order_note_id, :integer, null: false, after: :id
      t.change :submitted_by, :integer, null: false, after: :install_order_note_id
      t.change :text_body, :text, null: false, after: :submitted_by
      t.change :edit_summary, :string, after: :text_body
      t.change :submitted, :datetime, null: false, after: :edit_summary
      t.change :edited, :datetime, after: :submitted
    end

    # install order notes
    change_table "install_order_notes" do |t|
      t.change :game_id, :integer, null: false, after: :id
      t.change :submitted_by, :integer, null: false, after: :game_id
      t.change :first_mod_id, :integer, null: false, after: :submitted_by
      t.change :second_mod_id, :integer, null: false, after: :first_mod_id
      t.change :text_body, :text, null: false, after: :second_mod_id
      t.column :edit_summary, :string, after: :text_body
      t.change :moderator_message, :string, after: :edit_summary
      t.change :helpful_count, :integer, default: 0, null: false, after: :moderator_message
      t.change :not_helpful_count, :integer, default: 0, null: false, after: :helpful_count
      t.change :corrections_count, :integer, default: 0, null: false, after: :not_helpful_count
      t.change :history_entries_count, :integer, default: 0, null: false, after: :corrections_count
      t.change :approved, :boolean, default: false, null: false, after: :history_entries_count
      t.change :hidden, :boolean, default: false, null: false, after: :approved
      t.change :submitted, :datetime, null: false, after: :hidden
      t.change :edited, :datetime, after: :submitted
      t.remove :comments_count
    end

    # load order note history entries
    change_table "load_order_note_history_entries" do |t|
      t.change :load_order_note_id, :integer, null: false, after: :id
      t.change :submitted_by, :integer, null: false, after: :load_order_note_id
      t.change :text_body, :text, null: false, after: :submitted_by
      t.change :edit_summary, :string, after: :text_body
      t.change :submitted, :datetime, null: false, after: :edit_summary
      t.change :edited, :datetime, after: :submitted
    end

    # load order notes
    # TODO: Strong parameters for edit_summary
    change_table "load_order_notes" do |t|
      t.change :game_id, :integer, null: false, after: :id
      t.change :submitted_by, :integer, null: false, after: :game_id
      t.change :first_plugin_id, :integer, null: false, after: :submitted_by
      t.change :second_plugin_id, :integer, null: false, after: :first_plugin_id
      t.change :text_body, :text, null: false, after: :second_plugin_id
      t.column :edit_summary, :string, after: :text_body
      t.change :moderator_message, :string, after: :edit_summary
      t.change :helpful_count, :integer, default: 0, null: false, after: :moderator_message
      t.change :not_helpful_count, :integer, default: 0, null: false, after: :helpful_count
      t.change :corrections_count, :integer, default: 0, null: false, after: :not_helpful_count
      t.column :history_entries_count, :integer, default: 0, null: false, after: :corrections_count
      t.change :approved, :boolean, default: false, null: false, after: :history_entries_count
      t.change :hidden, :boolean, default: false, null: false, after: :approved
      t.change :submitted, :datetime, null: false, after: :hidden
      t.change :edited, :datetime, after: :submitted
    end

    # lover infos
    change_table "lover_infos" do |t|
      t.change :game_id, :integer, null: false, after: :id
      t.change :has_stats, :boolean, default: false, null: false, after: :game_id
      t.change :last_scraped, :datetime, after: :has_stats
      t.change :mod_id, :integer, after: :last_scraped
      t.change :mod_name, :string, null: false, after: :mod_id
      t.change :uploaded_by, :string, limit: 128, null: false, after: :mod_name
      t.rename :date_submitted, :released
      t.change :released, :datetime, null: false, after: :uploaded_by
      t.rename :date_updated, :updated
      t.change :updated, :datetime, after: :released
      t.change :current_version, :string, limit: 32, after: :updated
      t.change :views, :integer, default: 0, null: false, after: :current_version
      t.change :downloads, :integer, default: 0, null: false, after: :views
      t.change :followers_count, :integer, default: 0, null: false, after: :downloads
      t.change :file_size, :integer, default: 0, null: false, after: :followers_count
      t.change :has_adult_content, :boolean, default: true, null: false, after: :file_size
    end

    # masters
    change_table "masters" do |t|
      t.change :plugin_id, :integer, null: false
      t.change :master_plugin_id, :integer, null: false
      t.change :index, :integer, limit: 1, null: false
    end

    # mod asset files
    change_table "mod_asset_files" do |t|
      t.change :mod_id, :integer, null: false
      t.change :asset_file_id, :integer, null: false
    end

    # mod authors
    change_table "mod_authors" do |t|
      t.change :mod_id, :integer, null: false
      t.change :user_id, :integer, null: false
    end

    # mod list compatibility notes
    change_table "mod_list_compatibility_notes" do |t|
      t.change :mod_list_id, :integer, null: false
      t.change :compatibility_note_id, :integer, null: false
      t.change :status, :integer, limit: 1, default: 0, null: false
    end

    # mod list custom plugins
    change_table "mod_list_custom_plugins" do |t|
      t.change :mod_list_id, :integer, null: false
      t.change :index, :integer, limit: 2, null: false, after: :mod_list_id
      t.change :filename, :string, limit: 64, null: false, after: :index
      t.change :active, :boolean, default: true, null: false, after: :filename
    end

    # mod list install order notes
    change_table "mod_list_install_order_notes" do |t|
      t.change :mod_list_id, :integer, null: false
      t.change :install_order_note_id, :integer, null: false
      t.change :status, :integer, limit: 1, default: 0, null: false
    end

    # mod list load order notes
    change_table "mod_list_load_order_notes" do |t|
      t.change :mod_list_id, :integer, null: false
      t.change :load_order_note_id, :integer, null: false
      t.change :status, :integer, limit: 1, default: 0, null: false
    end

    # mod list mods
    change_table "mod_list_mods" do |t|
      t.change :mod_list_id, :integer, null: false
      t.change :mod_id, :integer, null: false
      t.change :index, :integer, limit: 2, null: false, after: :mod_id
      t.change :active, :boolean, default: true, null: false, after: :index
    end

    # mod list plugins
    change_table "mod_list_plugins" do |t|
      t.change :mod_list_id, :integer, null: false
      t.change :plugin_id, :integer, null: false
      t.change :index, :integer, limit: 2, null: false, after: :plugin_id
      t.change :active, :boolean, default: true, null: false, after: :index
    end

    # mod list stars
    change_table "mod_list_stars" do |t|
      t.change :mod_list_id, :integer, null: false
      t.change :user_id, :integer, null: false
    end

    # mod list tags
    change_table "mod_list_tags" do |t|
      t.change :mod_list_id, :integer, null: false, after: :id
      t.change :tag_id, :integer, null: false, after: :mod_list_id
      t.change :submitted_by, :integer, null: false, after: :tag_id
    end

    # mod lists
    remove_foreign_key :mod_lists, column: :created_by
    change_table "mod_lists" do |t|
      t.change :game_id, :integer, null: false, after: :id
      t.rename :created_by, :submitted_by
      t.change :submitted_by, :integer, null: false, after: :game_id
      t.change :status, :integer, limit: 1, null: false, after: :submitted_by
      t.column :visibility, :integer, limit: 1, default: 0, null: false, after: :status
      t.change :is_collection, :boolean, default: false, null: false, after: :visibility
      t.change :name, :string, null: false, after: :is_collection
      t.change :description, :text, after: :name
      t.change :mods_count, :integer, default: 0, null: false, after: :description
      t.change :plugins_count, :integer, default: 0, null: false, after: :mods_count
      t.change :active_plugins_count, :integer, default: 0, null: false, after: :plugins_count
      t.change :custom_plugins_count, :integer, default: 0, null: false, after: :active_plugins_count
      t.change :config_files_count, :integer, default: 0, null: false, after: :custom_plugins_count
      t.change :custom_config_files_count, :integer, default: 0, null: false, after: :config_files_count
      t.change :compatibility_notes_count, :integer, default: 0, null: false, after: :custom_config_files_count
      t.change :install_order_notes_count, :integer, default: 0, null: false, after: :compatibility_notes_count
      t.change :load_order_notes_count, :integer, default: 0, null: false, after: :install_order_notes_count
      t.change :tags_count, :integer, default: 0, null: false, after: :load_order_notes_count
      t.change :stars_count, :integer, default: 0, null: false, after: :tags_count
      t.change :comments_count, :integer, default: 0, null: false, after: :stars_count
      t.change :has_adult_content, :boolean, default: false, null: false, after: :comments_count
      t.change :hidden, :boolean, default: false, null: false, after: :has_adult_content
      t.change :submitted, :datetime, null: false, after: :hidden
      t.change :edited, :datetime, after: :submitted
    end
    add_foreign_key :mod_lists, :users, column: :submitted_by

    # mod stars
    change_table "mod_stars" do |t|
      t.change :mod_id, :integer, null: false
      t.change :user_id, :integer, null: false
    end

    # mod tags
    change_table "mod_tags" do |t|
      t.change :mod_id, :integer, null: false
      t.change :tag_id, :integer, null: false
      t.change :submitted_by, :integer, null: false
    end

    # mods
    change_table "mods" do |t|
      t.change :game_id, :integer, null: false, after: :id
      t.change :submitted_by, :integer, null: false, after: :game_id
      t.change :is_official, :boolean, default: false, null: false, after: :submitted_by
      t.change :is_utility, :boolean, default: false, null: false, after: :is_official
      t.change :name, :string, limit: 128, null: false, after: :is_utility
      t.change :aliases, :string, limit: 128, after: :name
      t.change :authors, :string, limit: 128, null: false, after: :aliases
      t.change :status, :integer, limit: 1, default: 0, null: false, after: :authors
      t.change :primary_category_id, :integer, after: :status
      t.change :secondary_category_id, :integer, after: :primary_category_id
      t.change :average_rating, :float, default: 0.0, null: false, after: :secondary_category_id
      t.change :reputation, :float, default: 0.0, null: false, after: :average_rating
      t.change :plugins_count, :integer, default: 0, null: false, after: :reputation
      t.change :asset_files_count, :integer, default: 0, null: false, after: :plugins_count
      t.change :required_mods_count, :integer, default: 0, null: false, after: :asset_files_count
      t.change :required_by_count, :integer, default: 0, null: false, after: :required_mods_Count
      t.change :tags_count, :integer, default: 0, null: false, after: :required_by_count
      t.change :stars_count, :integer, default: 0, null: false, after: :tags_count
      t.change :mod_lists_count, :integer, default: 0, null: false, after: :stars_count
      t.change :reviews_count, :integer, default: 0, null: false, after: :mod_lists_count
      t.change :compatibility_notes_count, :integer, default: 0, null: false, after: :reviews_count
      t.change :install_order_notes_count, :integer, default: 0, null: false, after: :compatibility_notes_count
      t.change :load_order_notes_count, :integer, default: 0, null: false, after: :install_order_notes_count
      t.column :corrections_count, :integer, default: 0, null: false, after: :load_order_notes_count
      t.change :has_adult_content, :boolean, default: false, null: false, after: :corrections_count
      t.change :hidden, :boolean, default: false, null: false, after: :has_adult_content
      t.change :released, :datetime, null: false, after: :hidden
      t.change :updated, :datetime, after: :released
    end

    # nexus infos
    NexusInfo.where(mod_name: nil).update_all(:mod_name => 'Test')
    change_table "nexus_infos" do |t|
      t.change :game_id, :integer, null: false, after: :id
      t.change :has_stats, :boolean, default: false, null: false, after: :game_id
      t.change :last_scraped, :datetime, after: :has_stats
      t.change :mod_id, :integer, after: :last_scraped
      t.change :mod_name, :string, null: false, after: :mod_id
      t.change :uploaded_by, :string, limit: 128, null: false, after: :mod_name
      t.change :authors, :string, limit: 128, null: false, after: :uploaded_by
      t.rename :date_added, :released
      t.change :released, :datetime, null: false, after: :authors
      t.rename :date_updated, :updated
      t.change :updated, :datetime, after: :released
      t.change :current_version, :string, limit: 32, after: :updated
      t.change :nexus_category, :integer, after: :current_version
      t.change :views, :integer, default: 0, null: false, after: :nexus_category
      t.rename :total_downloads, :downloads
      t.change :downloads, :integer, default: 0, null: false, after: :views
      t.change :endorsements, :integer, default: 0, null: false, after: :downloads
      t.change :unique_downloads, :integer, default: 0, null: false, after: :endorsements
      t.change :posts_count, :integer, default: 0, null: false, after: :unique_downloads
      t.column :discussions_count, :integer, default: 0, null: false, after: :posts_count
      t.change :articles_count, :integer, default: 0, null: false, after: :discussions_count
      t.column :bugs_count, :integer, default: 0, null: false, after: :articles_count
      t.change :files_count, :integer, default: 0, null: false, after: :bugs_count
      t.change :images_count, :integer, default: 0, null: false, after: :files_count
      t.change :videos_count, :integer, default: 0, null: false, after: :images_count
      t.column :has_adult_content, :boolean, default: false, null: false, after: :videos_count
      t.change :endorsement_rate, :float, default: 0.0, null: false, after: :has_adult_content
      t.change :dl_rate, :float, default: 0.0, null: false, after: :endorsement_rate
      t.change :udl_to_endorsements, :float, default: 0.0, null: false, after: :dl_rate
      t.change :udl_to_posts, :float, default: 0.0, null: false, after: :udl_to_endorsements
      t.change :tdl_to_udl, :float, default: 0.0, null: false, after: :udl_to_posts
      t.change :views_to_tdl, :float, default: 0.0, null: false, after: :tdl_to_udl
    end

    # override records
    change_table "override_records" do |t|
      t.change :plugin_id, :integer, null: false
      t.change :fid, :integer, null: false
      t.change :sig, :string, limit: 4, null: false
    end

    # plugin record groups
    change_table "plugin_record_groups" do |t|
      t.change :plugin_id, :integer, null: false
      t.change :sig, :string, limit: 4, null: false
      t.change :record_count, :integer, null: false
      t.change :override_count, :integer, null: false
    end

    # plugins
    change_table "plugins" do |t|
      t.change :game_id, :integer, null: false, after: :id
      t.change :mod_id, :integer, null: false, after: :game_id
      t.change :filename, :string, limit: 64, null: false, after: :mod_id
      t.change :crc_hash, :string, limit: 8, null: false, after: :filename
      t.change :file_size, :integer, null: false, after: :crc_hash
      t.change :author, :string, limit: 128, after: :file_size
      t.change :description, :string, limit: 512, after: :author
      t.change :record_count, :integer, default: 0, null: false, after: :description
      t.change :override_count, :integer, default: 0, null: false, after: :record_count
      t.change :errors_count, :integer, default: 0, null: false, after: :override_count
      t.change :mod_lists_count, :integer, default: 0, null: false, after: :errors_count
      t.change :load_order_notes_count, :integer, default: 0, null: false, after: :mod_lists_count
    end

    # record groups
    change_table "record_groups" do |t|
      t.change :game_id, :integer, null: false
      t.change :signature, :string, limit: 4, null: false
      t.change :name, :string, limit: 64, null: false
      t.change :child_group, :boolean, default: false, null: false
    end

    # reputation links
    change_table "reputation_links" do |t|
      t.change :from_rep_id, :integer, null: false
      t.change :to_rep_id, :integer, null: false
    end

    # review ratings
    change_table "review_ratings" do |t|
      t.change :review_id, :integer, null: false
      t.change :review_section_id, :integer, null: false
      t.change :rating, :integer, limit: 1, null: false
    end

    # review sections
    change_table "review_sections" do |t|
      t.change :category_id, :integer, null: false
      t.change :default, :boolean, default: false, null: false
    end

    # reviews
    change_table "reviews" do |t|
      t.change :game_id, :integer, null: false, after: :id
      t.change :submitted_by, :integer, null: false, after: :game_id
      t.change :mod_id, :integer, null: false, after: :submitted_by
      t.change :text_body, :text, null: false, after: :mod_id
      t.column :edit_summary, :string, after: :text_body
      t.change :moderator_message, :string, after: :edit_summary
      t.change :overall_rating, :float, default: 0.0, null: false, after: :moderator_message
      t.change :helpful_count, :integer, default: 0, null: false, after: :overall_rating
      t.change :not_helpful_count, :integer, default: 0, null: false, after: :helpful_count
      t.change :corrections_count, :integer, default: 0, null: false, after: :not_helpful_count
      t.column :history_entries_count, :integer, default: 0, null: false, after: :corrections_count
      t.change :ratings_count, :integer, default: 0, null: false, after: :history_entries_count
      t.change :approved, :boolean, default: false, null: false, after: :ratings_count
      t.change :hidden, :boolean, default: false, null: false, after: :approved
      t.change :submitted, :datetime, null: false, after: :hidden
      t.change :edited, :datetime, after: :submitted
    end

    # tags
    change_table "tags" do |t|
      t.change :game_id, :integer, null: false, after: :id
      t.change :submitted_by, :integer, null: false, after: :game_id
      t.change :text, :string, null: false, after: :submitted_by
      t.change :mods_count, :integer, default: 0, null: false, after: :text
      t.change :mod_lists_count, :integer, default: 0, null: false, after: :mods_count
      t.change :hidden, :boolean, default: false, null: false, after: :mod_lists_count
    end

    # user bios
    change_table "user_bios" do |t|
      t.change :user_id, :integer, null: false, after: :id
    end

    # user reputations
    UserReputation.update_all(site_rep: 0.0, contribution_rep: 0.0, author_rep: 0.0, given_rep: 0.0, dont_compute: false)
    change_table "user_reputations" do |t|
      t.change :user_id, :integer, null: false, after: :id
      t.change :overall, :float, default: 5.0, null: false, after: :user_id
      t.change :offset, :float, default: 5.0, null: false, after: :overall
      t.change :site_rep, :float, default: 0.0, null: false, after: :offset
      t.change :contribution_rep, :float, default: 0.0, null: false, after: :site_rep
      t.change :author_rep, :float, default: 0.0, null: false, after: :contribution_rep
      t.change :given_rep, :float, default: 0.0, null: false, after: :author_rep
      t.change :rep_from_count, :integer, default: 0, null: false, after: :given_rep
      t.change :rep_to_count, :integer, default: 0, null: false, after: :rep_from_count
      t.change :last_computed, :datetime, after: :rep_to_count
      t.change :dont_compute, :boolean, default: false, null: false, after: :last_computed
    end

    # user settings
    change_table "user_settings" do |t|
      t.change :user_id, :integer, null: false, after: :id
      t.change :theme, :string, limit: 64, after: :user_id
      t.change :allow_comments, :boolean, default: true, null: false, after: :theme
      t.change :show_notifications, :boolean, default: true, null: false, after: :allow_comments
      t.change :email_notifications, :boolean, default: true, null: false, after: :show_notifications
      t.change :email_public, :boolean, default: true, null: false, after: :email_notifications
      t.change :allow_adult_content, :boolean, default: true, null: false, after: :email_public
      t.change :allow_nexus_mods, :boolean, default: true, null: false, after: :allow_adult_content
      t.change :allow_lovers_lab, :boolean, default: true, null: false, after: :allow_nexus_mods
      t.change :allow_steam_workshop, :boolean, default: true, null: false, after: :allow_lovers_lab
      t.remove :show_tooltips
      t.remove :timezone
      t.remove :udate_format
      t.remove :utime_format
    end

    # user titles
    change_table "user_titles" do |t|
      t.change :game_id, :integer, null: false
      t.change :title, :string, limit: 32, null: false
      t.change :rep_required, :integer, limit: 4, null: false
    end

    # users
    change_table "users" do |t|
      t.change :username, :string, limit: 32, null: false, after: :id
      t.change :email, :string, limit: 255, null: false, after: :username
      t.change :role, :string, limit: 16, null: false, after: :email
      t.change :title, :string, limit: 32, after: :role
      t.change :active_mod_list_id, :integer, after: :title
      t.change :about_me, :text, after: :active_mod_list_id
      t.change :comments_count, :integer, default: 0, null: false, after: :about_me
      t.change :authored_mods_count, :integer, default: 0, null: false, after: :comments_count
      t.change :submitted_mods_count, :integer, default: 0, null: false, after: :authored_mods_count
      t.change :reviews_count, :integer, default: 0, null: false, after: :submitted_mods_count
      t.change :compatibility_notes_count, :integer, default: 0, null: false, after: :reviews_count
      t.change :install_order_notes_count, :integer, default: 0, null: false, after: :compatibility_notes_count
      t.change :load_order_notes_count, :integer, default: 0, null: false, after: :install_order_notes_count
      t.change :corrections_count, :integer, default: 0, null: false, after: :load_order_notes_count
      t.change :submitted_comments_count, :integer, default: 0, null: false, after: :corrections_count
      t.change :mod_lists_count, :integer, default: 0, null: false, after: :submitted_comments_count
      t.change :mod_collections_count, :integer, default: 0, null: false, after: :mod_lists_count
      t.change :tags_count, :integer, default: 0, null: false, after: :mod_collections_count
      t.change :mod_tags_count, :integer, default: 0, null: false, after: :tags_count
      t.change :mod_list_tags_count, :integer, default: 0, null: false, after: :mod_tags_count
      t.change :helpful_marks_count, :integer, default: 0, null: false, after: :mod_list_tags_count
      t.change :agreement_marks_count, :integer, default: 0, null: false, after: :helpful_marks_count
      t.change :starred_mods_count, :integer, default: 0, null: false, after: :agreement_marks_count
      t.change :starred_mod_lists_count, :integer, default: 0, null: false, after: :starred_mods_count
      t.change :joined, :datetime, null: false, after: :starred_mod_lists_count
    end

    # workshop infos
    change_table "workshop_infos" do |t|
      t.change :game_id, :integer, null: false, after: :id
      t.change :has_stats, :boolean, default: false, null: false, after: :game_id
      t.change :last_scraped, :datetime, after: :has_stats
      t.change :mod_id, :integer, after: :last_scraped
      t.change :mod_name, :string, null: false, after: :mod_id
      t.change :uploaded_by, :string, limit: 128, null: false, after: :mod_name
      t.rename :date_submitted, :released
      t.change :released, :datetime, null: false, after: :uploaded_by
      t.rename :date_updated, :updated
      t.change :updated, :datetime, after: :released
      t.change :views, :integer, default: 0, null: false, after: :updated
      t.change :subscribers, :integer, default: 0, null: false, after: :views
      t.change :favorites, :integer, default: 0, null: false, after: :subscribers
      t.change :file_size, :integer, default: 0, null: false, after: :favorites
      t.rename :comments_count, :posts_count
      t.change :posts_count, :integer, default: 0, null: false, after: :file_size
      t.change :discussions_count, :integer, default: 0, null: false, after: :posts_count
      t.change :images_count, :integer, default: 0, null: false, after: :discussions_count
      t.change :videos_count, :integer, default: 0, null: false, after: :images_count
      t.remove :average_rating
      t.remove :ratings_count
    end
  end
end
