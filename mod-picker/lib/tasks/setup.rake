namespace :setup do
  desc "Tasks for setup"

  task unsigned: :environment do
    connection = ActiveRecord::Base.connection
    puts "\nSetting up unsigned columns"
    connection.execute("ALTER TABLE agreement_marks MODIFY incorrect_note_id INT UNSIGNED;")
    connection.execute("ALTER TABLE agreement_marks MODIFY submitted_by INT UNSIGNED;")

    connection.execute("ALTER TABLE categories MODIFY id INT UNSIGNED NOT NULL AUTO_INCREMENT;")
    connection.execute("ALTER TABLE categories MODIFY parent_id INT UNSIGNED;")

    connection.execute("ALTER TABLE category_priorities MODIFY dominant_id INT UNSIGNED;")
    connection.execute("ALTER TABLE category_priorities MODIFY recessive_id INT UNSIGNED;")

    connection.execute("ALTER TABLE comments MODIFY id INT UNSIGNED NOT NULL AUTO_INCREMENT;")
    connection.execute("ALTER TABLE comments MODIFY submitted_by INT UNSIGNED;")
    connection.execute("ALTER TABLE comments MODIFY parent_comment INT UNSIGNED;")
    connection.execute("ALTER TABLE comments MODIFY commentable_id INT UNSIGNED;")

    connection.execute("ALTER TABLE compatibility_notes MODIFY id INT UNSIGNED NOT NULL AUTO_INCREMENT;")
    connection.execute("ALTER TABLE compatibility_notes MODIFY submitted_by INT UNSIGNED;")
    connection.execute("ALTER TABLE compatibility_notes MODIFY compatibility_plugin_id INT UNSIGNED;")
    connection.execute("ALTER TABLE compatibility_notes MODIFY installation_note_id INT UNSIGNED;")

    connection.execute("ALTER TABLE games MODIFY id INT UNSIGNED NOT NULL AUTO_INCREMENT;")

    connection.execute("ALTER TABLE helpful_marks MODIFY submitted_by INT UNSIGNED;")
    connection.execute("ALTER TABLE helpful_marks MODIFY helpfulable_id INT UNSIGNED;")

    connection.execute("ALTER TABLE incorrect_notes MODIFY id INT UNSIGNED NOT NULL AUTO_INCREMENT;")
    connection.execute("ALTER TABLE incorrect_notes MODIFY submitted_by INT UNSIGNED;")
    connection.execute("ALTER TABLE incorrect_notes MODIFY correctable_id INT UNSIGNED")

    connection.execute("ALTER TABLE installation_notes MODIFY id INT UNSIGNED NOT NULL AUTO_INCREMENT;")
    connection.execute("ALTER TABLE installation_notes MODIFY submitted_by INT UNSIGNED;")
    connection.execute("ALTER TABLE installation_notes MODIFY mod_version_id INT UNSIGNED;")

    connection.execute("ALTER TABLE lover_infos MODIFY id INT UNSIGNED NOT NULL AUTO_INCREMENT;")
    connection.execute("ALTER TABLE lover_infos MODIFY mod_id INT UNSIGNED;")

    connection.execute("ALTER TABLE masters MODIFY id INT UNSIGNED NOT NULL AUTO_INCREMENT;")
    connection.execute("ALTER TABLE masters MODIFY plugin_id INT UNSIGNED;")

    connection.execute("ALTER TABLE mod_asset_files MODIFY id INT UNSIGNED NOT NULL AUTO_INCREMENT;")

    connection.execute("ALTER TABLE mod_authors MODIFY mod_id INT UNSIGNED;")
    connection.execute("ALTER TABLE mod_authors MODIFY user_id INT UNSIGNED;")

    connection.execute("ALTER TABLE mod_list_compatibility_notes MODIFY mod_list_id INT UNSIGNED;")
    connection.execute("ALTER TABLE mod_list_compatibility_notes MODIFY compatibility_note_id INT UNSIGNED;")

    connection.execute("ALTER TABLE mod_list_custom_plugins MODIFY mod_list_id INT UNSIGNED;")

    connection.execute("ALTER TABLE mod_list_installation_notes MODIFY mod_list_id INT UNSIGNED;")
    connection.execute("ALTER TABLE mod_list_installation_notes MODIFY installation_note_id INT UNSIGNED;")

    connection.execute("ALTER TABLE mod_list_mods MODIFY mod_list_id INT UNSIGNED;")
    connection.execute("ALTER TABLE mod_list_mods MODIFY mod_id INT UNSIGNED;")

    connection.execute("ALTER TABLE mod_list_plugins MODIFY mod_list_id INT UNSIGNED;")
    connection.execute("ALTER TABLE mod_list_plugins MODIFY plugin_id INT UNSIGNED;")

    connection.execute("ALTER TABLE mod_list_stars MODIFY mod_list_id INT UNSIGNED;")
    connection.execute("ALTER TABLE mod_list_stars MODIFY user_id INT UNSIGNED;")

    connection.execute("ALTER TABLE mod_lists MODIFY id INT UNSIGNED NOT NULL AUTO_INCREMENT;")
    connection.execute("ALTER TABLE mod_lists MODIFY created_by INT UNSIGNED;")
    connection.execute("ALTER TABLE mod_lists MODIFY game_id INT UNSIGNED;")

    connection.execute("ALTER TABLE mod_stars MODIFY mod_id INT UNSIGNED;")
    connection.execute("ALTER TABLE mod_stars MODIFY user_id INT UNSIGNED;")

    connection.execute("ALTER TABLE mod_version_compatibility_notes MODIFY mod_version_id INT UNSIGNED;")
    connection.execute("ALTER TABLE mod_version_compatibility_notes MODIFY compatibility_note_id INT UNSIGNED;")

    connection.execute("ALTER TABLE mod_version_files MODIFY mod_version_id INT UNSIGNED;")
    connection.execute("ALTER TABLE mod_version_files MODIFY mod_asset_file_id INT UNSIGNED;")

    connection.execute("ALTER TABLE mod_versions MODIFY id INT UNSIGNED NOT NULL AUTO_INCREMENT;")
    connection.execute("ALTER TABLE mod_versions MODIFY mod_id INT UNSIGNED;")

    connection.execute("ALTER TABLE mods MODIFY id INT UNSIGNED NOT NULL AUTO_INCREMENT;")
    connection.execute("ALTER TABLE mods MODIFY game_id INT UNSIGNED;")
    connection.execute("ALTER TABLE mods MODIFY primary_category_id INT UNSIGNED;")
    connection.execute("ALTER TABLE mods MODIFY secondary_category_id INT UNSIGNED;")

    connection.execute("ALTER TABLE nexus_infos MODIFY id INT UNSIGNED NOT NULL AUTO_INCREMENT;")
    connection.execute("ALTER TABLE nexus_infos MODIFY mod_id INT UNSIGNED;")

    connection.execute("ALTER TABLE override_records MODIFY plugin_id INT UNSIGNED;")
    connection.execute("ALTER TABLE override_records MODIFY master_id INT UNSIGNED;")

    connection.execute("ALTER TABLE plugin_record_groups MODIFY plugin_id INT UNSIGNED;")

    connection.execute("ALTER TABLE plugins MODIFY id INT UNSIGNED NOT NULL AUTO_INCREMENT;")
    connection.execute("ALTER TABLE plugins MODIFY mod_version_id INT UNSIGNED;")

    connection.execute("ALTER TABLE record_groups MODIFY id INT UNSIGNED NOT NULL AUTO_INCREMENT;")
    connection.execute("ALTER TABLE record_groups MODIFY game_id INT UNSIGNED;")

    connection.execute("ALTER TABLE reputation_links MODIFY from_rep_id INT UNSIGNED;")
    connection.execute("ALTER TABLE reputation_links MODIFY to_rep_id INT UNSIGNED;")

    connection.execute("ALTER TABLE reviews MODIFY id INT UNSIGNED NOT NULL AUTO_INCREMENT;")
    connection.execute("ALTER TABLE reviews MODIFY submitted_by INT UNSIGNED;")
    connection.execute("ALTER TABLE reviews MODIFY mod_id INT UNSIGNED;")

    connection.execute("ALTER TABLE user_bios MODIFY id INT UNSIGNED NOT NULL AUTO_INCREMENT;")
    connection.execute("ALTER TABLE user_bios MODIFY user_id INT UNSIGNED;")

    connection.execute("ALTER TABLE user_reputations MODIFY id INT UNSIGNED NOT NULL AUTO_INCREMENT;")
    connection.execute("ALTER TABLE user_reputations MODIFY user_id INT UNSIGNED;")

    connection.execute("ALTER TABLE user_settings MODIFY id INT UNSIGNED NOT NULL AUTO_INCREMENT;")
    connection.execute("ALTER TABLE user_settings MODIFY user_id INT UNSIGNED;")

    connection.execute("ALTER TABLE users MODIFY id INT UNSIGNED NOT NULL AUTO_INCREMENT;")
    connection.execute("ALTER TABLE users MODIFY active_ml_id INT UNSIGNED;")
    connection.execute("ALTER TABLE users MODIFY active_mc_id INT UNSIGNED;")

    connection.execute("ALTER TABLE workshop_infos MODIFY id INT UNSIGNED NOT NULL AUTO_INCREMENT;")
    connection.execute("ALTER TABLE workshop_infos MODIFY mod_id INT UNSIGNED;")
    puts "    Unsigned columns set up"
  end

<<<<<<< HEAD
  namespace :reset do
    task ids: :environment do
      puts "\nResetting IDs"
      connection = ActiveRecord::Base.connection
      connection.execute("ALTER TABLE categories AUTO_INCREMENT = 0;")
      connection.execute("ALTER TABLE user_bios AUTO_INCREMENT = 0;")
      connection.execute("ALTER TABLE user_reputations AUTO_INCREMENT = 0;")
      connection.execute("ALTER TABLE user_settings AUTO_INCREMENT = 0;")
      connection.execute("ALTER TABLE users AUTO_INCREMENT = 0;")
      connection.execute("ALTER TABLE nexus_infos AUTO_INCREMENT = 0;")
      connection.execute("ALTER TABLE lover_infos AUTO_INCREMENT = 0;")
      connection.execute("ALTER TABLE workshop_infos AUTO_INCREMENT = 0;")
      connection.execute("ALTER TABLE mods AUTO_INCREMENT = 0;")
      connection.execute("ALTER TABLE mod_versions AUTO_INCREMENT = 0;")
      connection.execute("ALTER TABLE games AUTO_INCREMENT = 0;")
      connection.execute("ALTER TABLE comments AUTO_INCREMENT = 0;")
      connection.execute("ALTER TABLE reviews AUTO_INCREMENT = 0;")
      connection.execute("ALTER TABLE compatibility_notes AUTO_INCREMENT = 0;")
      connection.execute("ALTER TABLE install_order_notes AUTO_INCREMENT = 0;")
      connection.execute("ALTER TABLE load_order_notes AUTO_INCREMENT = 0;")
      puts "    IDs reset"
    end

    task db: :environment do
      puts "\nResetting database"
      connection = ActiveRecord::Base.connection

      # tables
      OverrideRecord.delete_all
      Master.delete_all
      DummyMaster.delete_all
      PluginRecordGroup.delete_all
      PluginError.delete_all
      Plugin.delete_all
      Quote.delete_all
      ModList.delete_all
      ModAuthor.delete_all
      PluginRecordGroup.delete_all
      RecordGroup.delete_all
      ModVersionCompatibilityNote.delete_all
      ModVersionLoadOrderNote.delete_all
      ModVersionInstallOrderNote.delete_all
      CompatibilityNote.delete_all
      InstallOrderNote.delete_all
      LoadOrderNote.delete_all
      HelpfulMark.delete_all
      Review.delete_all
      Comment.delete_all
      NexusInfo.delete_all
      LoverInfo.delete_all
      WorkshopInfo.delete_all
      ModVersion.delete_all
      Mod.delete_all
      UserBio.delete_all
      UserReputation.delete_all
      UserSetting.delete_all
      User.delete_all
      Game.delete_all
      CategoryPriority.delete_all

      # clear categories
      connection.execute("DELETE FROM categories WHERE parent_id IS NOT NULL;")
      connection.execute("DELETE FROM categories WHERE parent_id IS NULL;")
      puts "    Database reset"
    end
  end

=======
>>>>>>> f1fbc2e3b4903c07372d1f876d6bd549096cded4
end
