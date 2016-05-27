namespace :setup do
  desc "Tasks for setup"

  task unsigned: :environment do
    connection = ActiveRecord::Base.connection
    puts "\nSetting up unsigned columns"
    connection.execute("ALTER TABLE agreement_marks MODIFY correction_id INT UNSIGNED;")
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

    connection.execute("ALTER TABLE corrections MODIFY id INT UNSIGNED NOT NULL AUTO_INCREMENT;")
    connection.execute("ALTER TABLE corrections MODIFY submitted_by INT UNSIGNED;")
    connection.execute("ALTER TABLE corrections MODIFY correctable_id INT UNSIGNED")

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

end
