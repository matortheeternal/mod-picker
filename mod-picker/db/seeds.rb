#==================================================
# HELPER METHODS
#==================================================

def randpow(num, pow)
  result = 1.0
  for i in 1..pow
    result *= rand(10000)/10000.0
  end
  (num * result).floor
end

#==================================================
# CONFIGURATION OPTIONS
#==================================================

bSeedUsers = true
bSeedComments = true
bSeedReviews = true
bSeedCNotes = true
bSeedINotes = true

#==================================================
# CREATE GAMES
#==================================================

puts "\nSeeding games"

gameSkyrim = Game.create(
    display_name: "Skyrim",
    long_name: "The Elder Scrolls V: Skyrim",
    abbr_name: "sk",
    exe_name: "TESV.exe",
    nexus_name: "skyrim",
    steam_app_ids: "72850"
)
gameOblivion = Game.create(
    display_name: "Oblivion",
    long_name: "The Elder Scrolls IV: Oblivion",
    abbr_name: "ob",
    exe_name: "Oblivion.exe",
    nexus_name: "oblivion",
    steam_app_ids: "22330,900883"
)
gameFallout4 = Game.create(
    display_name: "Fallout 4",
    long_name: "Fallout 4",
    abbr_name: "fo4",
    exe_name: "Fallout4.exe",
    nexus_name: "fallout4",
    steam_app_ids: "377160"
)
gameFalloutNV = Game.create(
    display_name: "Fallout NV",
    long_name: "Fallout: New Vegas",
    abbr_name: "fnv",
    exe_name: "FalloutNV.exe",
    nexus_name: "newvegas",
    steam_app_ids: "22380,2028016"
)
gameFallout3 = Game.create(
    display_name: "Fallout 3",
    long_name: "Fallout 3",
    abbr_name: "fo3",
    exe_name: "Fallout3.exe",
    nexus_name: "fallout3",
    steam_app_ids: "22300,22370"
)

puts "    #{Game.count} games seeded"


#==================================================
# CREATE SUPER-CATEGORIES
#==================================================

puts "\nSeeding categories"

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

puts "    #{Category.count} super-categories seeded"


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

puts "    #{Category.where.not(parent_id: nil).count} sub-categories seeded"


#==================================================
# CREATE USERS
#==================================================
require 'securerandom'

if (bSeedUsers)
  puts "\nSeeding users"
  # create an admin user
  pw = SecureRandom.urlsafe_base64
  User.create!(
      username: "admin",
      user_level: "admin",
      title: "God",
      joined: Time.now.to_date,
      email: "admin@mail.com",
      password: pw,
      password_confirmation: pw,
      sign_in_count: 1,
      confirmed_at: Time.now.to_date,
      current_sign_in_at: Time.now.to_date,
      last_sign_in_at: Time.now.to_date,
      current_sign_in_ip: Faker::Internet.public_ip_v4_address,
      last_sign_in_ip: Faker::Internet.public_ip_v4_address
  )
  puts "    admin seeded with password: #{pw}"

  # generates random date between year 2000 and now.
  def time_rand from = Time.new(2000), to = Time.now
    Time.at(from + rand * (to.to_f - from.to_f)).to_date
  end

  # create 99 random users
  99.times do |n|
    name = Faker::Internet.user_name
    pw = SecureRandom.urlsafe_base64
    User.create!(
        username: "#{name}#{n}",
        joined: time_rand,
        email: Faker::Internet.email(name),
        password: pw,
        password_confirmation: pw,
        confirmed_at: Time.now.to_date,
        reset_password_token: Faker::Internet.password,
        sign_in_count: Random.rand(100).to_i + 1,
        current_sign_in_ip: Faker::Internet.public_ip_v4_address,
        last_sign_in_at: Time.now.to_date,
        last_sign_in_ip: Faker::Internet.public_ip_v4_address
    )
  end
  puts "    #{User.count} users seeded"
end


#==================================================
# CREATE SAMPLE MODS
#==================================================

puts "\nSeeding mods, nexus infos, and mod versions"

# Helper vars
nexusDateFormat = "%d/%m/%Y - %I:%M%p"

# Top recently endorsed mods
Mod.create(
    name: "SkyUI",
    primary_category_id: Category.where(name: "Gameplay - User Interface").first.id,
    secondary_category_id: Category.where(name: "Resources - Frameworks").first.id,
    is_utility: false,
    has_adult_content: false,
    game_id: gameSkyrim.id
)

NexusInfo.create(
    id: 3863,
    mod_id: Mod.last.id,
    game_id: gameSkyrim.id,
    uploaded_by: "schlangster",
    authors: "SkyUI Team",
    date_added: DateTime.strptime("17/12/2011 - 12:24AM", nexusDateFormat),
    date_updated: DateTime.strptime("24/08/2015 - 03:38PM", nexusDateFormat),
    endorsements: 404927,
    total_downloads: 11244061,
    unique_downloads: 5703525,
    views: 26258557,
    posts_count: 17040,
    videos_count: 23,
    images_count: 23,
    files_count: 14,
    articles_count: 1,
    nexus_category: 42
)

ModVersion.create(
    mod_id: Mod.last.id,
    version: "5.1",
    released: DateTime.strptime("24/08/2015 - 03:38PM", nexusDateFormat),
    obsolete: false,
    dangerous: false
)

Mod.create(
    name: "Immersive Armors",
    primary_category_id: Category.where(name: "Items - Armor, Clothing, & Accessories").first.id,
    is_utility: false,
    has_adult_content: false,
    game_id: gameSkyrim.id
)

NexusInfo.create(
    id: 19733,
    mod_id: Mod.last.id,
    game_id: gameSkyrim.id,
    uploaded_by: "hothtrooper44",
    authors: "Hothtrooper44",
    date_added: DateTime.strptime("01/07/2012 - 07:23PM", nexusDateFormat),
    date_updated: DateTime.strptime("20/01/2016 - 12:16AM", nexusDateFormat),
    endorsements: 208078,
    total_downloads: 6423440,
    unique_downloads: 2936645,
    views: 16208593,
    posts_count: 15646,
    videos_count: 16,
    images_count: 454,
    files_count: 25,
    articles_count: 3,
    nexus_category: 54
)

ModVersion.create(
    mod_id: Mod.last.id,
    version: "8",
    released: DateTime.strptime("20/01/2016 - 12:16AM", nexusDateFormat),
    obsolete: false,
    dangerous: false
)

Mod.create(
    name: "Skyrim HD - 2K Textures",
    primary_category_id: Category.where(name: "Audiovisual - Models & Textures").first.id,
    is_utility: false,
    has_adult_content: false,
    game_id: gameSkyrim.id
)

NexusInfo.create(
    id: 607,
    mod_id: Mod.last.id,
    game_id: gameSkyrim.id,
    uploaded_by: "NebuLa1",
    authors: "NebuLa from AHBmods",
    date_added: DateTime.strptime("19/11/2011 - 01:03AM", nexusDateFormat),
    date_updated: DateTime.strptime("09/01/2016 - 04:57PM", nexusDateFormat),
    endorsements: 158069,
    total_downloads: 17720870,
    unique_downloads: 8524444,
    views: 20530426,
    posts_count: 8494,
    videos_count: 26,
    images_count: 161,
    files_count: 23,
    articles_count: 0,
    nexus_category: 29
)

ModVersion.create(
    mod_id: Mod.last.id,
    version: "1.7",
    released: DateTime.strptime("09/01/2016 - 04:57PM", nexusDateFormat),
    obsolete: false,
    dangerous: false
)

Mod.create(
    name: "RaceMenu",
    primary_category_id: Category.where(name: "Gameplay - User Interface").first.id,
    secondary_category_id: Category.where(name: "Resources - Frameworks").first.id,
    is_utility: false,
    has_adult_content: false,
    game_id: gameSkyrim.id
)

NexusInfo.create(
    id: 29624,
    mod_id: Mod.last.id,
    game_id: gameSkyrim.id,
    uploaded_by: "expired6978",
    authors: "Expired",
    date_added: DateTime.strptime("08/01/2013 - 01:10AM", nexusDateFormat),
    date_updated: DateTime.strptime("18/01/2016 - 10:37AM", nexusDateFormat),
    endorsements: 148874,
    total_downloads: 4187681,
    unique_downloads: 2890642,
    views: 9661000,
    posts_count: 10047,
    videos_count: 8,
    images_count: 258,
    files_count: 104,
    articles_count: 0,
    nexus_category: 42
)

ModVersion.create(
    mod_id: Mod.last.id,
    version: "3.4.5",
    released: DateTime.strptime("18/01/2016 - 10:37AM", nexusDateFormat),
    obsolete: false,
    dangerous: false
)

Mod.create(
    name: "Unofficial Skyrim Legendary Edition Patch",
    primary_category_id: Category.where(name: "Fixes").first.id,
    is_utility: false,
    has_adult_content: false,
    game_id: gameSkyrim.id
)

NexusInfo.create(
    id: 71214,
    mod_id: Mod.last.id,
    game_id: gameSkyrim.id,
    uploaded_by: "Arthmoor",
    authors: "Unofficial Patch Project Team ",
    date_added: DateTime.strptime("07/11/2015 - 08:41PM", nexusDateFormat),
    date_updated: DateTime.strptime("20/01/2016 - 06:41PM", nexusDateFormat),
    endorsements: 14628,
    total_downloads: 272979,
    unique_downloads: 183781,
    views: 742126,
    posts_count: 1703,
    videos_count: 1,
    images_count: 15,
    files_count: 1,
    articles_count: 0,
    nexus_category: 84
)

ModVersion.create(
    mod_id: Mod.last.id,
    version: "3.0.0",
    released: DateTime.strptime("20/01/2016 - 06:41PM", nexusDateFormat),
    obsolete: false,
    dangerous: false
)

Mod.create(
    name: "Mod Organizer",
    primary_category_id: Category.where(name: "Utilities - Tools").first.id,
    is_utility: true,
    has_adult_content: false,
    game_id: gameSkyrim.id
)

NexusInfo.create(
    id: 1334,
    mod_id: Mod.last.id,
    game_id: gameSkyrim.id,
    uploaded_by: "Tannin42",
    authors: "Tannin",
    date_added: DateTime.strptime("24/11/2011 - 03:30PM", nexusDateFormat),
    date_updated: DateTime.strptime("01/12/2015 - 09:23PM", nexusDateFormat),
    endorsements: 88697,
    total_downloads: 2078942,
    unique_downloads: 1507428,
    views: 4833168,
    posts_count: 13016,
    videos_count: 35,
    images_count: 4,
    files_count: 27,
    articles_count: 0,
    nexus_category: 39
)

ModVersion.create(
    mod_id: Mod.last.id,
    version: "1.3.11",
    released: DateTime.strptime("01/12/2015 - 09:23PM", nexusDateFormat),
    obsolete: false,
    dangerous: false
)

Mod.create(
    name: "Skyrim Flora Overhaul",
    primary_category_id: Category.where(name: "Audiovisual - Models & Textures").first.id,
    is_utility: false,
    has_adult_content: false,
    game_id: gameSkyrim.id
)

NexusInfo.create(
    id: 141,
    mod_id: Mod.last.id,
    game_id: gameSkyrim.id,
    uploaded_by: "vurt",
    authors: "vurt",
    date_added: DateTime.strptime("13/11/2011 - 10:36PM", nexusDateFormat),
    date_updated: DateTime.strptime("16/01/2016 - 10:15PM", nexusDateFormat),
    endorsements: 99308,
    total_downloads: 5225456,
    unique_downloads: 3342510,
    views: 10248390,
    posts_count: 10586,
    videos_count: 47,
    images_count: 741,
    files_count: 35,
    articles_count: 0,
    nexus_category: 29
)

ModVersion.create(
    mod_id: Mod.last.id,
    version: "2.3",
    released: DateTime.strptime("16/01/2016 - 10:15PM", nexusDateFormat),
    obsolete: false,
    dangerous: false
)

Mod.create(
    name: "TES5Edit",
    primary_category_id: Category.where(name: "Utilities - Tools").first.id,
    secondary_category_id: Category.where(name: "Resources - Frameworks").first.id,
    is_utility: true,
    has_adult_content: false,
    game_id: gameSkyrim.id
)

NexusInfo.create(
    id: 25859,
    mod_id: Mod.last.id,
    game_id: gameSkyrim.id,
    uploaded_by: "Sharlikran",
    authors: "ElminsterAU",
    date_added: DateTime.strptime("22/10/2012 - 06:22AM", nexusDateFormat),
    date_updated: DateTime.strptime("10/11/2015 - 07:43AM", nexusDateFormat),
    endorsements: 80385,
    total_downloads: 1597970,
    unique_downloads: 1162331,
    views: 4606415,
    posts_count: 0,
    videos_count: 14,
    images_count: 4,
    files_count: 6,
    articles_count: 0,
    nexus_category: 39
)

ModVersion.create(
    mod_id: Mod.last.id,
    version: "3.1.2",
    released: DateTime.strptime("10/11/2015 - 07:43AM", nexusDateFormat),
    obsolete: false,
    dangerous: false
)

# Top mods in the last 59 days
Mod.create(
    name: "Merge Plugins",
    primary_category_id: Category.where(name: "Utilities - Tools").first.id,
    is_utility: true,
    has_adult_content: false,
    game_id: gameSkyrim.id
)

NexusInfo.create(
    id: 69905,
    mod_id: Mod.last.id,
    game_id: gameSkyrim.id,
    uploaded_by: "matortheeternal",
    authors: "Mator",
    date_added: DateTime.strptime("24/12/2015 - 01:56AM", nexusDateFormat),
    date_updated: DateTime.strptime("05/01/2016 - 09:16AM", nexusDateFormat),
    endorsements: 1099,
    total_downloads: 12487,
    unique_downloads: 11147,
    views: 92672,
    posts_count: 701,
    videos_count: 0,
    images_count: 15,
    files_count: 3,
    articles_count: 0,
    nexus_category: 39
)

ModVersion.create(
    mod_id: Mod.last.id,
    version: "2.1.3",
    released: DateTime.strptime("05/01/2016 - 09:16AM", nexusDateFormat),
    obsolete: false,
    dangerous: false
)

Mod.create(
    name: "The Lily - Armour Mashup",
    primary_category_id: Category.where(name: "Items - Armor, Clothing, & Accessories").first.id,
    is_utility: false,
    has_adult_content: false,
    game_id: gameSkyrim.id
)

NexusInfo.create(
    id: 71843,
    mod_id: Mod.last.id,
    game_id: gameSkyrim.id,
    uploaded_by: "pottoply",
    authors: "pottoply",
    date_added: DateTime.strptime("08/12/2015 - 09:42PM", nexusDateFormat),
    date_updated: DateTime.strptime("19/01/2016 - 07:58PM", nexusDateFormat),
    endorsements: 921,
    total_downloads: 23264,
    unique_downloads: 19418,
    views: 122787,
    posts_count: 207,
    videos_count: 6,
    images_count: 46,
    files_count: 15,
    articles_count: 0,
    nexus_category: 54
)

ModVersion.create(
    mod_id: Mod.last.id,
    version: "1.6",
    released: DateTime.strptime("19/01/2016 - 07:58PM", nexusDateFormat),
    obsolete: false,
    dangerous: false
)

Mod.create(
    name: "THE PEOPLE OF SKYRIM ULTIMATE EDITION",
    primary_category_id: Category.where(name: "Gameplay - Immersion & Role-playing").first.id,
    secondary_category_id: Category.where(name: "New Characters").first.id,
    is_utility: false,
    has_adult_content: false,
    game_id: gameSkyrim.id
)

NexusInfo.create(
    id: 72449,
    mod_id: Mod.last.id,
    game_id: gameSkyrim.id,
    uploaded_by: "nesbit098",
    authors: "Nesbit",
    date_added: DateTime.strptime("05/01/2016 - 10:31AM", nexusDateFormat),
    date_updated: DateTime.strptime("24/01/2016 - 02:41AM", nexusDateFormat),
    endorsements: 970,
    total_downloads: 57197,
    unique_downloads: 37661,
    views: 196131,
    posts_count: 1397,
    videos_count: 0,
    images_count: 26,
    files_count: 29,
    articles_count: 3,
    nexus_category: 78
)

ModVersion.create(
    mod_id: Mod.last.id,
    version: "3.0.6.5",
    released: DateTime.strptime("24/01/2016 - 02:41AM", nexusDateFormat),
    obsolete: false,
    dangerous: false
)

Mod.create(
    name: "Skaal You Need - Skaal house and follower",
    primary_category_id: Category.where(name: "Locations - New Player Homes").first.id,
    secondary_category_id: Category.where(name: "New Characters - Allies").first.id,
    is_utility: false,
    has_adult_content: false,
    game_id: gameSkyrim.id
)

NexusInfo.create(
    id: 72005,
    mod_id: Mod.last.id,
    game_id: gameSkyrim.id,
    uploaded_by: "Elianora",
    authors: "Elianora",
    date_added: DateTime.strptime("17/12/2015 - 09:23PM", nexusDateFormat),
    date_updated: DateTime.strptime("20/01/2016 - 07:36PM", nexusDateFormat),
    endorsements: 737,
    total_downloads: 12276,
    unique_downloads: 9996,
    views: 96800,
    posts_count: 242,
    videos_count: 2,
    images_count: 35,
    files_count: 4,
    articles_count: 0,
    nexus_category: 67
)

ModVersion.create(
    mod_id: Mod.last.id,
    version: "1.0",
    released: DateTime.strptime("20/01/2016 - 07:36PM", nexusDateFormat),
    obsolete: false,
    dangerous: false
)

Mod.create(
    name: "SC - Hairstyles",
    primary_category_id: Category.where(name: "Character Appearance - Face Parts").first.id,
    is_utility: false,
    has_adult_content: false,
    game_id: gameSkyrim.id
)

NexusInfo.create(
    id: 71561,
    mod_id: Mod.last.id,
    game_id: gameSkyrim.id,
    uploaded_by: "ShinglesCat",
    authors: "ShinglesCat",
    date_added: DateTime.strptime("25/11/2015 - 09:21AM", nexusDateFormat),
    date_updated: DateTime.strptime("02/01/2016 - 06:11PM", nexusDateFormat),
    endorsements: 650,
    total_downloads: 10243,
    unique_downloads: 8640,
    views: 90865,
    posts_count: 98,
    videos_count: 3,
    images_count: 61,
    files_count: 2,
    articles_count: 0,
    nexus_category: 26
)

ModVersion.create(
    mod_id: Mod.last.id,
    version: "1.1",
    released: DateTime.strptime("02/01/2016 - 06:11PM", nexusDateFormat),
    obsolete: false,
    dangerous: false
)

Mod.create(
    name: "Real Names",
    primary_category_id: Category.where(name: "Gameplay - Immersion & Role-playing").first.id,
    is_utility: false,
    has_adult_content: false,
    game_id: gameSkyrim.id
)

NexusInfo.create(
    id: 71464,
    mod_id: Mod.last.id,
    game_id: gameSkyrim.id,
    uploaded_by: "nellshini",
    authors: "Jaxonz and Nellshini",
    date_added: DateTime.strptime("23/11/2015 - 02:11AM", nexusDateFormat),
    date_updated: DateTime.strptime("21/01/2016 - 07:01AM", nexusDateFormat),
    endorsements: 665,
    total_downloads: 11142,
    unique_downloads: 9654,
    views: 47429,
    posts_count: 166,
    videos_count: 0,
    images_count: 6,
    files_count: 4,
    articles_count: 0,
    nexus_category: 78
)

ModVersion.create(
    mod_id: Mod.last.id,
    version: "2.25",
    released: DateTime.strptime("21/01/2016 - 07:01AM", nexusDateFormat),
    obsolete: false,
    dangerous: false
)

puts "    #{Mod.count} mods seeded"
puts "    #{NexusInfo.count} nexus infos seeded"
puts "    #{ModVersion.count} mod versions seeded"


#==================================================
# CREATE COMMENTS
#==================================================

if (bSeedComments)
  # generate comments on user profiles
  puts "\nSeeding user comments"
  for user in User.all
    rnd = randpow(10, 2)
    puts "    Generating #{rnd} comments for #{user.username}"
    rnd.times do
      submitter = User.offset(rand(User.count)).first
      user.profile_comments.new(
          submitted_by: submitter.id,
          hidden: false,
          submitted: Faker::Date.backward(14),
          text_body: Faker::Lorem.paragraph(1)
      ).save!
    end
  end

  # generate comments on mods
  puts "\nSeeding mod comments"
  for mod in Mod.all
    rnd = randpow(20, 2)
    puts "    Generating #{rnd} comments for #{mod.name}"
    rnd.times do
      submitter = User.offset(rand(User.count)).first
      mod.comments.new(
          submitted_by: submitter.id,
          hidden: false,
          submitted: Faker::Date.backward(14),
          text_body: Faker::Lorem.paragraph(2)
      ).save!
    end
  end
end


#==================================================
# CREATE REVIEWS
#==================================================

if (bSeedReviews)
  # generate reviews on mods
  puts "\nSeeding reviews"
  for mod in Mod.all
    nReviews = rand(6)
    puts "    Generating #{nReviews} reviews for #{mod.name}"
    nReviews.times do
      submitter = User.offset(rand(User.count)).first
      review = mod.reviews.new(
          submitted_by: submitter.id,
          mod_id: mod.id,
          hidden: false,
          rating1: 100 - randpow(100, 3),
          rating2: 100 - randpow(100, 3),
          rating3: 100 - randpow(100, 3),
          rating4: 100 - randpow(100, 3),
          rating5: -1,
          submitted: DateTime.now,
          text_body: Faker::Lorem.paragraph(15)
      )
      review.save!

      # seed helpful marks on reviews
      nHelpfulMarks = randpow(10, 3)
      nHelpfulMarks.times do
        submitter = User.offset(rand(User.count)).first
        review.helpful_marks.new(
            submitted_by: submitter.id,
            helpful: rand > 0.35
        ).save!
      end
    end
  end
end


#==================================================
# CREATE COMPATIBILTIY NOTES
#==================================================

if (bSeedCNotes)
  puts "\nSeeding compatibility notes"
  nCNotes = Mod.count
  nCNotes.times do
    submitter = User.offset(rand(User.count)).first
    cnote = CompatibilityNote.new(
        submitted_by: submitter.id,
        mod_mode: ["Any", "All"].sample,
        compatibility_status: ["Incompatible", "Partially Compatible", "Patch Available", "Make Custom Patch",
                               "Soft Incompatibility", "Installation Note"].sample,
        submitted: Faker::Date.backward(14),
        text_body: Faker::Lorem.paragraph(4)
    )
    cnote.save!

    # seed helpful marks on cnotes
    nHelpfulMarks = randpow(10, 3)
    nHelpfulMarks.times do
      submitter = User.offset(rand(User.count)).first
      cnote.helpful_marks.new(
          submitted_by: submitter.id,
          helpful: rand > 0.35
      ).save!
    end

    # associate the compatibility note with some mod versions
    nModVersions = 2 + randpow(3, 5)
    puts "    Generating compatibility note associated with:"
    nModVersions.times do
      mod_version = ModVersion.offset(rand(ModVersion.count)).first
      mod_version.compatibility_notes << cnote
      puts "      - #{mod_version.mod.name} v#{mod_version.version}"
    end
  end
end


#==================================================
# CREATE INSTALLATION NOTES
#==================================================

if (bSeedINotes)
  puts "\nSeeding installation notes"
  nINotes = Mod.count
  nINotes.times do
    submitter = User.offset(rand(User.count)).first
    mod_version = ModVersion.offset(rand(ModVersion.count)).first
    puts "    Generating installation note for #{mod_version.mod.name}"
    inote = InstallationNote.new(
        submitted_by: submitter.id,
        mod_version_id: mod_version.id,
        always: rand(2) == 1,
        note_type: ["Download Option", "FOMOD Option"].sample,
        submitted: Faker::Date.backward(14),
        text_body: Faker::Lorem.paragraph(4)
    )
    inote.save!

    # seed helpful marks on inotes
    nHelpfulMarks = randpow(10, 3)
    nHelpfulMarks.times do
      submitter = User.offset(rand(User.count)).first
      inote.helpful_marks.new(
          submitted_by: submitter.id,
          helpful: rand > 0.35
      ).save!
    end
  end
end
