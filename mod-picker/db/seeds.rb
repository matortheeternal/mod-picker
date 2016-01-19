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
UserBio.delete_all
UserReputation.delete_all
UserSetting.delete_all
User.delete_all
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


#==================================================
# CREATE SAMPLE MODS
#==================================================

# Helper vars
nexusDateFormat = "%k:%M, %d %b %Y"

# Top recently endorsed mods
Mod.create(
    name: "SkyUI",
    primary_category: Category.where(name: "Gameplay - User Interface").first.id,
    secondary_category: Category.where(name: "Resources - Frameworks").first.id,
    game_id: gameSkyrim.id
)

NexusInfo.create(
    mod_id: Mod.last.id,
    uploaded_by: "schlangster",
    authors: "SkyUI Team",
    date_released: DateTime.strptime(" 0:24, 17 Dec 2011", nexusDateFormat),
    date_updated: DateTime.strptime("15:38, 24 Aug 2015", nexusDateFormat),
    endorsements: 401363,
    total_downloads: 11193037,
    unique_downloads: 5677583,
    views: 26147936,
    posts_count: 17023,
    videos_count: 23,
    images_count: 23,
    files_count: 14,
    articles_count: 1,
    nexus_category: 42
)