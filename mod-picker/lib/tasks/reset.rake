namespace :reset do
  desc "Tasks for resetting the database when bad things happen"

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
    connection = ActiveRecord::Base.connection

    # tables
    ModListTag.delete_all
    ModTag.delete_all
    ModAssetFile.delete_all
    AssetFile.delete_all
    Tag.delete_all
    ModStar.delete_all
    ModListStar.delete_all
    Quote.delete_all
    ModList.destroy_all
    ModAuthor.delete_all
    OverrideRecord.delete_all
    PluginError.delete_all
    PluginRecordGroup.delete_all
    DummyMaster.delete_all
    Master.delete_all
    Plugin.delete_all
    RecordGroup.delete_all
    ModRequirement.delete_all
    CompatibilityNote.delete_all
    InstallOrderNote.delete_all
    LoadOrderNote.delete_all
    HelpfulMark.delete_all
    ReviewRating.delete_all
    Review.delete_all
    ReviewSection.delete_all
    Comment.delete_all
    NexusInfo.delete_all
    LoverInfo.delete_all
    WorkshopInfo.delete_all
    CustomSource.delete_all
    Mod.delete_all
    UserBio.delete_all
    UserReputation.delete_all
    UserSetting.delete_all
    UserTitle.delete_all
    User.delete_all
    CategoryPriority.delete_all

    # clear games
    Game.where.not(parent_game_id: nil).delete_all
    Game.where(parent_game_id: nil).delete_all

    # clear categories
    Category.where.not(parent_id: nil).delete_all
    Category.where(parent_id: nil).delete_all
    puts "    Database reset"
  end
end