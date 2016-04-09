namespace :reset do
  desc "Tasks for resetting the database when bad things happen"

  task ids: :environment do
    puts "\nResetting IDs"
    connection = ActiveRecord::Base.connection()
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

  task clear: :environment do
    puts "\nResetting database"
    connection = ActiveRecord::Base.connection()

    # tables
    Plugin.delete_all
    ModStar.delete_all
    ModListStar.delete_all
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