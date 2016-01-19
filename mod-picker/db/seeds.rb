#==================================================
# CONFIGURATION OPTIONS
#==================================================

bSeedUsers = false

#==================================================
# CLEAR TABLES
#==================================================

connection = ActiveRecord::Base.connection()
# clear mods and associated tables
NexusInfo.delete_all
LoverInfo.delete_all
WorkshopInfo.delete_all
Mod.delete_all
# clear categories
connection.execute("DELETE FROM categories WHERE parent_id IS NOT NULL;")
connection.execute("DELETE FROM categories WHERE parent_id IS NULL;")
# clear users and associated tables
if (bSeedUsers)
  UserBio.delete_all
  UserReputation.delete_all
  UserSetting.delete_all
  User.delete_all
end
# clear games
Game.delete_all

# reset auto increment counters
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

#==================================================
# CREATE GAMES
#==================================================

gameSkyrim = Game.create(
    short_name: "Skyrim",
    long_name: "The Elder Scrolls V: Skyrim",
    abbr_name: "sk",
    exe_name: "TESV.exe",
    steam_app_ids: "72850"
)
gameOblivion = Game.create(
    short_name: "Oblivion",
    long_name: "The Elder Scrolls IV: Oblivion",
    abbr_name: "ob",
    exe_name: "Oblivion.exe",
    steam_app_ids: "22330,900883"
)
gameFallout4 = Game.create(
    short_name: "Fallout43",
    long_name: "Fallout 4",
    abbr_name: "fo4",
    exe_name: "Fallout4.exe",
    steam_app_ids: "377160"
)
gameFalloutNV = Game.create(
    short_name: "FalloutNV",
    long_name: "Fallout: New Vegas",
    abbr_name: "fnv",
    exe_name: "FalloutNV.exe",
    steam_app_ids: "22380,2028016"
)
gameFallout3 = Game.create(
    short_name: "Fallout3",
    long_name: "Fallout 3",
    abbr_name: "fo3",
    exe_name: "Fallout3.exe",
    steam_app_ids: "22300,22370"
)


#==================================================
# CREATE SUPER-CATEGORIES
#==================================================

catUtilities = Category.create(
    name: "Utilities",
    description: "These also aren’t necessarily mods, but they can be.  These are tools to aid in the creation and management of mods and mod-related assets."
)
catResources = Category.create(
    name: "Resources",
    description: "These aren't necessarily mods, but they can be.  These are files which are resources to be used by other modders or mod-users."
)
catPatches = Category.create(
    name: "Patches",
    description: "Mods that make mods compatible with each other, or carry the changes from one mod into another."
)
catLocations = Category.create(
    name: "Locations",
    description: "Mods which add or modify locations ingame."
)
catGameplay = Category.create(
    name: "Gameplay",
    description: "Mods classify as Gameplay mods if they alter any game mechanics, pardigms, balance, or events."
)
catCharacter = Category.create(
    name: "Character Appearance",
    description: "Mods that modify the appearance of non-player characters in the game or give you additional options for customizing the player character’s appearance."
)
catNewChars = Category.create(
    name: "New Characters",
    description: "Mods that add new non-playable characters to the game."
)
catItems = Category.create(
    name: "Items",
    description: "Mods are categorized as Item mods when they add new items to the game.  E.g. new armor, clothing, weapons, food, potions, poisons, ingredients, etc."
)
catFixes = Category.create(
    name: "Fixes",
    description: "Fixes are mods that fix issues (bugs) in the vanilla game without adding new content."
)
catAudiovisual = Category.create(
    name: "Audiovisual",
    description: "Audiovisual mods are mods which strictly alter the visuals/audio in the game.  So any mod that is strictly graphical or audial would belong in this category.  This category is often superseded by other categories."
)

#==================================================
# CREATE SUB-CATEGORIES
#==================================================

# Utilities sub-categories
Category.create(
    name: "Utilities - Ingame",
    parent_id: catUtilities.id,
    description: "Any utility that exists ingame/has an ingame interface."
)
Category.create(
    name: "Utilities - Patchers",
    parent_id: catUtilities.id,
    description: "A utility for generating some kind of patch or mod.  E.g. SkyProc patchers, TES5Edit patchers, etc."
)
Category.create(
    name: "Utilities - Tools",
    parent_id: catUtilities.id,
    description: "A utility which allows you to create, edit, or manage mod-related files."
)

# Resources sub-categories
Category.create(
    name: "Resources - Audiovisual",
    parent_id: catResources.id,
    description: "Models, textures, animations, sounds, and music made available for other modders to freely use as resources for their mods."
)
Category.create(
    name: "Resources - Frameworks",
    parent_id: catResources.id,
    description: "Frameworks offer functionality for other mods or tools to build off of.  Frameworks often don’t change much in the game on their own, but enable other mods to do so.  Some frameworks do change aspects of the game."
)
Category.create(
    name: "Resources - Guides & Tutorials",
    parent_id: catResources.id,
    description: "Any resource that is a guide or tutorial."
)

# Locations sub-categories
Category.create(
    name: "Locations - Overhauls",
    parent_id: catLocations.id,
    description: "Mods which overhaul or build off of one or more vanilla locations.  E.g. City Overhauls, Player Home Overhauls, etc."
)
Category.create(
    name: "Locations - New Lands",
    parent_id: catLocations.id,
    description: "Mods which add completely new lands to explore."
)
Category.create(
    name: "Locations - New Player Homes",
    parent_id: catLocations.id,
    description: "Mods which add new player homes to the game.  This include all sorts of residences ranging from tree houses to castles."
)
Category.create(
    name: "Locations - New Dungeons",
    parent_id: catLocations.id,
    description: "Mods which add new areas where you encounter and fight enemies."
)
Category.create(
    name: "Locations - New Structures & Landmarks",
    parent_id: catLocations.id,
    description: "Mods which add new structures or landmarks, e.g. Cities, Towns, Inns, Statues, etc."
)

# Gameplay sub-categories
Category.create(
    name: "Gameplay - Classes and Races",
    parent_id: catGameplay.id,
    description: "Mods that add or alter character classes or races."
)
Category.create(
    name: "Gameplay - Crafting",
    parent_id: catGameplay.id,
    description: "Any mod which modifies the alchemy, enchanting, or smithing systems in the game.  Also includes mods which modify other crafting systems or add new crafting systems."
)
Category.create(
    name: "Gameplay - Combat",
    parent_id: catGameplay.id,
    description: "Mods which alter combat, or enemy strength in general."
)
Category.create(
    name: "Gameplay - Economy & Balance",
    parent_id: catGameplay.id,
    description: "Mods which alter the economy of the game - viz., the acquisition of items and currency.  E.g. modifications to merchants or leveled loot.  Also includes mods which rebalance items, e.g. their weight, gold value, and armor rating/damage."
)
Category.create(
    name: "Gameplay - Factions",
    parent_id: catGameplay.id,
    description: "Mods which alter existing factions and faction quest lines or add new ones."
)
Category.create(
    name: "Gameplay - Immersion & Role-playing",
    parent_id: catGameplay.id,
    description: "Mods which exist specifically to increase the player’s immersion in the game world, or to aid in role-playing."
)
Category.create(
    name: "Gameplay - Magic",
    parent_id: catGameplay.id,
    description: "Mods which add new spells, or magic-based mechanics to the game.  Note: Mods that only alter magic-related perk trees should go into Gameplay - Skills & Perks."
)
Category.create(
    name: "Gameplay - Quests",
    parent_id: catGameplay.id,
    description: "Mods which add or alter quests in the game."
)
Category.create(
    name: "Gameplay - Skills & Perks",
    parent_id: catGameplay.id,
    description: "Mods which modify skills or perks in the game, or add new ones."
)
Category.create(
    name: "Gameplay - Stealth",
    parent_id: catGameplay.id,
    description: "Mods which modify the mechanics of detection, pickpocketing, or lockpicking.  Also includes mods which add new stealth-based mechanics."
)
Category.create(
    name: "Gameplay - User Interface",
    parent_id: catGameplay.id,
    description: "Mods which alter or add to the main user interface ingame."
)

# Character Appearance sub-categories
Category.create(
    name: "Character Appearance - Face Parts",
    parent_id: catCharacter.id,
    description: "Mods that add new face parts.  E.g. Hairs, beards, brows, eyes, and noses."
)
Category.create(
    name: "Character Appearance - Overlays",
    parent_id: catCharacter.id,
    description: "Mods that add new overlays for characters.  That is, warpaints, tattoos, freckles, tanlines, pimples, chest hair, etc."
)
Category.create(
    name: "Character Appearance - NPC Overhauls",
    parent_id: catCharacter.id,
    description: "Mods that overhaul NPCs with different faces/outfits."
)

# New Characters sub-categories
Category.create(
    name: "New Characters - Allies",
    parent_id: catNewChars.id,
    description: "If one or more NPCs added by the mod can be allies of the player character, the mod belongs here."
)
Category.create(
    name: "New Characters - Neutral",
    parent_id: catNewChars.id,
    description: "If most of the NPCs added by the mod don’t have a disposition to help or hurt the player, put it here."
)
Category.create(
    name: "New Characters - Enemies",
    parent_id: catNewChars.id,
    description: "Mods that add NPCs that try to bash your head in.  Whether they be dragons or flesh-eating bunnies!"
)

# Items sub-categories
Category.create(
    name: "Items - Armor, Clothing, & Accessories",
    parent_id: catItems.id,
    description: "Mods that add items that can be worn in the major biped slots.  This includes armor, clothing, jewelry, cloaks, bags, etc."
)
Category.create(
    name: "Items - Ingestibles",
    parent_id: catItems.id,
    description: "Mods that add items you can eat or drink.  This includes alchemical ingredients."
)
Category.create(
    name: "Items - Tools & Clutter",
    parent_id: catItems.id,
    description: "Mods that add items that cannot be worn, ingested, or used as a weapon."
)
Category.create(
    name: "Items - Weapons",
    parent_id: catItems.id,
    description: "Mods that that add sticks you can stab, squish, or shoot people with."
)

# Fixes sub-categories
Category.create(
    name: "Fixes - Stability & Performance",
    parent_id: catFixes.id,
    description: "A fix that specifically increases game stability or performance."
)

# Audiovisual sub-categories
Category.create(
    name: "Audiovisual - Animations",
    parent_id: catAudiovisual.id,
    description: "Any mod which adds or alters animations."
)
Category.create(
    name: "Audiovisual - Lighting & Weather",
    parent_id: catAudiovisual.id,
    description: "Any mod which alters lighting or weather."
)
Category.create(
    name: "Audiovisual - Models & Textures",
    parent_id: catAudiovisual.id,
    description: "Any mod which provides modified models/textures without introducing new items, excluding character mods."
)
Category.create(
    name: "Audiovisual - Post-processing",
    parent_id: catAudiovisual.id,
    description: "Any mod which provides a post-processing preset, e.g. ENB or SweetFX."
)
Category.create(
    name: "Audiovisual - Sounds & Music",
    parent_id: catAudiovisual.id,
    description: "Any mod which alters or adds sounds or music to the game."
)


#==================================================
# CREATE USERS
#==================================================
require 'securerandom'

if (bSeedUsers)
  # create an admin user
  User.create!(
      username: "admin",
      user_level: "admin",
      title: "God",
      avatar: "",
      joined: Time.now.to_date,
      email: "admin@mail.com",
      password: SecureRandom.urlsafe_base64,
      encrypted_password: SecureRandom.urlsafe_base64,
      reset_password_token: "foobarpw",
      sign_in_count: 1,
      current_sign_in_at: Time.now.to_date,
      last_sign_in_at: Time.now.to_date,
      current_sign_in_ip: Faker::Internet.public_ip_v4_address,
      last_sign_in_ip: Faker::Internet.public_ip_v4_address
  )

  # generates random date between year 2000 and now.
  def time_rand from = Time.new(2000), to = Time.now
    Time.at(from + rand * (to.to_f - from.to_f)).to_date
  end

  # create 99 random users
  99.times do |n|
    name = Faker::Internet.user_name
    User.create!(
        username: "#{name}#{n}",
        joined: time_rand,
        email: Faker::Internet.email(name),
        password: SecureRandom.urlsafe_base64,
        encrypted_password: SecureRandom.urlsafe_base64,
        reset_password_token: Faker::Internet.password,
        sign_in_count: Random.rand(100).to_i + 1,
        current_sign_in_ip: Faker::Internet.public_ip_v4_address,
        last_sign_in_at: Time.now.to_date,
        last_sign_in_ip: Faker::Internet.public_ip_v4_address
    )
  end
end


#==================================================
# CREATE SAMPLE MODS
#==================================================

# Helper vars
nexusDateFormat = "%d/%m/%Y - %I:%M%p"

# Top recently endorsed mods
Mod.create(
    name: "SkyUI",
    primary_category: Category.where(name: "Gameplay - User Interface").first.id,
    secondary_category: Category.where(name: "Resources - Frameworks").first.id,
    game_id: gameSkyrim.id
)

NexusInfo.create(
    mod_id: 3863,
    uploaded_by: "schlangster",
    authors: "SkyUI Team",
    date_released: DateTime.strptime("17/12/2011 - 12:24AM", nexusDateFormat),
    date_updated: DateTime.strptime("24/08/2015 - 03:38PM", nexusDateFormat),
    endorsements: 401489,
    total_downloads: 11195070,
    unique_downloads: 5678653,
    views: 26151968,
    posts_count: 17023,
    videos_count: 23,
    images_count: 23,
    files_count: 14,
    articles_count: 1,
    nexus_category: 42
)

Mod.create(
    name: "Immersive Armors",
    primary_category: Category.where(name: "Items - Armor, Clothing, & Accessories").first.id,
    game_id: gameSkyrim.id
)

NexusInfo.create(
    mod_id: 19733,
    uploaded_by: "hothtrooper44",
    authors: "Hothtrooper44",
    date_released: DateTime.strptime("01/07/2012 - 07:23PM", nexusDateFormat),
    date_updated: DateTime.strptime("11/01/2016 - 01:51AM", nexusDateFormat),
    endorsements: 206379,
    total_downloads: 6391803,
    unique_downloads: 2920317,
    views: 16140841,
    posts_count: 15626,
    videos_count: 16,
    images_count: 453,
    files_count: 25,
    articles_count: 3,
    nexus_category: 54
)

Mod.create(
    name: "Skyrim HD - 2K Textures",
    primary_category: Category.where(name: "Audiovisual - Models & Textures").first.id,
    game_id: gameSkyrim.id
)

NexusInfo.create(
    mod_id: 607,
    uploaded_by: "NebuLa1",
    authors: "NebuLa from AHBmods",
    date_released: DateTime.strptime("19/11/2011 - 01:03AM", nexusDateFormat),
    date_updated: DateTime.strptime("09/01/2016 - 04:57PM", nexusDateFormat),
    endorsements: 156555,
    total_downloads: 17682800,
    unique_downloads: 8505445,
    views: 20440708,
    posts_count: 8472,
    videos_count: 26,
    images_count: 161,
    files_count: 23,
    articles_count: 0,
    nexus_category: 29
)

Mod.create(
    name: "RaceMenu",
    primary_category: Category.where(name: "Gameplay - User Interface").first.id,
    secondary_category: Category.where(name: "Resources - Frameworks").first.id,
    game_id: gameSkyrim.id
)

NexusInfo.create(
    mod_id: 29624,
    uploaded_by: "expired6978",
    authors: "Expired",
    date_released: DateTime.strptime("08/01/2013 - 01:10AM", nexusDateFormat),
    date_updated: DateTime.strptime("18/01/2016 - 10:37AM", nexusDateFormat),
    endorsements: 147455,
    total_downloads: 4160279,
    unique_downloads: 2874155,
    views: 9600050,
    posts_count: 9998,
    videos_count: 8,
    images_count: 258,
    files_count: 104,
    articles_count: 0,
    nexus_category: 42
)

Mod.create(
    name: "Unofficial Skyrim Legendary Edition Patch",
    primary_category: Category.where(name: "Fixes").first.id,
    game_id: gameSkyrim.id
)

NexusInfo.create(
    mod_id: 71214,
    uploaded_by: "Arthmoor",
    authors: "Unofficial Patch Project Team ",
    date_released: DateTime.strptime("07/11/2015 - 08:41PM", nexusDateFormat),
    date_updated: DateTime.strptime("11/01/2016 - 07:37PM", nexusDateFormat),
    endorsements: 13221,
    total_downloads: 249042,
    unique_downloads: 168964,
    views: 681548,
    posts_count: 1604,
    videos_count: 1,
    images_count: 15,
    files_count: 1,
    articles_count: 0,
    nexus_category: 84
)

Mod.create(
    name: "Mod Organizer",
    primary_category: Category.where(name: "Utilities - Tools").first.id,
    game_id: gameSkyrim.id
)

NexusInfo.create(
    mod_id: 1334,
    uploaded_by: "Tannin42",
    authors: "Tannin",
    date_released: DateTime.strptime("24/11/2011 - 03:30PM", nexusDateFormat),
    date_updated: DateTime.strptime("01/12/2015 - 09:23PM", nexusDateFormat),
    endorsements: 87747,
    total_downloads: 2062125,
    unique_downloads: 1496783,
    views: 4795316,
    posts_count: 12997,
    videos_count: 35,
    images_count: 4,
    files_count: 27,
    articles_count: 0,
    nexus_category: 39
)

Mod.create(
    name: "Skyrim Flora Overhaul",
    primary_category: Category.where(name: "Audiovisual - Models & Textures").first.id,
    game_id: gameSkyrim.id
)

NexusInfo.create(
    mod_id: 141,
    uploaded_by: "vurt",
    authors: "vurt",
    date_released: DateTime.strptime("13/11/2011 - 10:36PM", nexusDateFormat),
    date_updated: DateTime.strptime("16/01/2016 - 10:15PM", nexusDateFormat),
    endorsements: 98473,
    total_downloads: 5201828,
    unique_downloads: 3329262,
    views: 10208445,
    posts_count: 10565,
    videos_count: 47,
    images_count: 741,
    files_count: 35,
    articles_count: 0,
    nexus_category: 29
)

Mod.create(
    name: "TES5Edit",
    primary_category: Category.where(name: "Utilities - Tools").first.id,
    secondary_category: Category.where(name: "Resources - Frameworks").first.id,
    game_id: gameSkyrim.id
)

NexusInfo.create(
    mod_id: 25859,
    uploaded_by: "Sharlikran",
    authors: "ElminsterAU",
    date_released: DateTime.strptime("22/10/2012 - 06:22AM", nexusDateFormat),
    date_updated: DateTime.strptime("10/11/2015 - 07:43AM", nexusDateFormat),
    endorsements: 79734,
    total_downloads: 1586957,
    unique_downloads: 1154565,
    views: 4577626,
    posts_count: 0,
    videos_count: 14,
    images_count: 4,
    files_count: 6,
    articles_count: 0,
    nexus_category: 39
)

# Top mods in the last 59 days
Mod.create(
    name: "Merge Plugins",
    primary_category: Category.where(name: "Utilities - Tools").first.id,
    game_id: gameSkyrim.id
)

NexusInfo.create(
    mod_id: 69905,
    uploaded_by: "matortheeternal",
    authors: "Mator",
    date_released: DateTime.strptime("24/12/2015 - 01:56AM", nexusDateFormat),
    date_updated: DateTime.strptime("05/01/2016 - 09:16AM", nexusDateFormat),
    endorsements: 1024,
    total_downloads: 11444,
    unique_downloads: 10295,
    views: 84413,
    posts_count: 661,
    videos_count: 0,
    images_count: 15,
    files_count: 3,
    articles_count: 0,
    nexus_category: 39
)

Mod.create(
    name: "The Lily - Armour Mashup",
    primary_category: Category.where(name: "Items - Armor, Clothing, & Accessories").first.id,
    game_id: gameSkyrim.id
)

NexusInfo.create(
    mod_id: 71843,
    uploaded_by: "pottoply",
    authors: "pottoply",
    date_released: DateTime.strptime("08/12/2015 - 09:42PM", nexusDateFormat),
    date_updated: DateTime.strptime("01/01/2016 - 08:21PM", nexusDateFormat),
    endorsements: 881,
    total_downloads: 22009,
    unique_downloads: 18444,
    views: 119147,
    posts_count: 206,
    videos_count: 5,
    images_count: 45,
    files_count: 15,
    articles_count: 0,
    nexus_category: 54
)

Mod.create(
    name: "THE PEOPLE OF SKYRIM ULTIMATE EDITION",
    primary_category: Category.where(name: "Gameplay - Immersion & Role-playing").first.id,
    secondary_category: Category.where(name: "New Characters").first.id,
    game_id: gameSkyrim.id
)

NexusInfo.create(
    mod_id: 72449,
    uploaded_by: "nesbit098",
    authors: "Nesbit",
    date_released: DateTime.strptime("05/01/2016 - 10:31AM", nexusDateFormat),
    date_updated: DateTime.strptime("19/01/2016 - 03:32AM", nexusDateFormat),
    endorsements: 740,
    total_downloads: 48840,
    unique_downloads: 31636,
    views: 169100,
    posts_count: 1215,
    videos_count: 0,
    images_count: 18,
    files_count: 29,
    articles_count: 3,
    nexus_category: 78
)

Mod.create(
    name: "Skaal You Need - Skaal house and follower",
    primary_category: Category.where(name: "Locations - New Player Homes").first.id,
    secondary_category: Category.where(name: "New Characters - Allies").first.id,
    game_id: gameSkyrim.id
)

NexusInfo.create(
    mod_id: 72005,
    uploaded_by: "Elianora",
    authors: "Elianora",
    date_released: DateTime.strptime("17/12/2015 - 09:23PM", nexusDateFormat),
    date_updated: DateTime.strptime("29/12/2015 - 08:16PM", nexusDateFormat),
    endorsements: 705,
    total_downloads: 11941,
    unique_downloads: 9776,
    views: 94548,
    posts_count: 240,
    videos_count: 2,
    images_count: 35,
    files_count: 4,
    articles_count: 0,
    nexus_category: 67
)

Mod.create(
    name: "SC - Hairstyles",
    primary_category: Category.where(name: "Character Appearance - Face Parts").first.id,
    game_id: gameSkyrim.id
)

NexusInfo.create(
    mod_id: 71561,
    uploaded_by: "ShinglesCat",
    authors: "ShinglesCat",
    date_released: DateTime.strptime("25/11/2015 - 09:21AM", nexusDateFormat),
    date_updated: DateTime.strptime("02/01/2016 - 06:11PM", nexusDateFormat),
    endorsements: 632,
    total_downloads: 10011,
    unique_downloads: 8458,
    views: 89746,
    posts_count: 98,
    videos_count: 3,
    images_count: 61,
    files_count: 2,
    articles_count: 0,
    nexus_category: 26
)

Mod.create(
    name: "Real Names",
    primary_category: Category.where(name: "Gameplay - Immersion & Role-playing").first.id,
    game_id: gameSkyrim.id
)

NexusInfo.create(
    mod_id: 71464,
    uploaded_by: "nellshini",
    authors: "Jaxonz and Nellshini",
    date_released: DateTime.strptime("23/11/2015 - 02:11AM", nexusDateFormat),
    date_updated: DateTime.strptime("16/01/2016 - 08:36PM", nexusDateFormat),
    endorsements: 628,
    total_downloads: 10530,
    unique_downloads: 9121,
    views: 45741,
    posts_count: 163,
    videos_count: 0,
    images_count: 6,
    files_count: 3,
    articles_count: 0,
    nexus_category: 78
)

