def create_plugin(mod, dump_filename)
  file = File.read(Rails.root.join("db", "dumps", dump_filename))
  hash = JSON.parse(file).with_indifferent_access
  hash[:game_id] = mod.game_id
  mod.plugins.create(hash).save!
end

def create_config_file(mod, config_filename, config_install_path)
  file = File.read(Rails.root.join("db", "config_files", config_filename))
  hash = {
      game_id: mod.game_id,
      filename: config_filename,
      install_path: config_install_path,
      text_body: file
  }
  mod.config_files.create(hash).save!
end

def generate_password
  if Rails.env.production?
    pw = SecureRandom.urlsafe_base64
    puts "    Secure password: #{pw}"
    pw
  else
    'password'
  end
end


def seed_staff_users
  puts "\nSeeding staff users"

  staff_password = generate_password
  User.create!(
      username: "Mator",
      role: "admin",
      title: "teh autoMator",
      joined: Time.now.to_date,
      email: "mator.eternal@gmail.com",
      password: staff_password,
      password_confirmation: staff_password,
      confirmed_at: Time.now.to_date
  )
  User.create!(
      username: "TerrorFox1234",
      role: "moderator",
      title: "foxy girl",
      joined: Time.now.to_date,
      email: "avaluxaudio@gmail.com",
      password: staff_password,
      password_confirmation: staff_password,
      confirmed_at: Time.now.to_date
  )
  User.create!(
      username: "Thallassa",
      role: "moderator",
      title: "spirit of the sea",
      joined: Time.now.to_date,
      email: "phaedrathallassa@gmail.com",
      password: staff_password,
      password_confirmation: staff_password,
      confirmed_at: Time.now.to_date
  )
  User.create!(
      username: "Sirius",
      role: "moderator",
      joined: Time.now.to_date,
      email: "thesiriusadam@gmail.com",
      password: staff_password,
      password_confirmation: staff_password,
      confirmed_at: Time.now.to_date
  )
  User.create!(
      username: "Taffy",
      role: "moderator",
      joined: Time.now.to_date,
      email: "r@r79.io",
      password: staff_password,
      password_confirmation: staff_password,
      confirmed_at: Time.now.to_date
  )
  User.create!(
      username: "ThreeTen",
      role: "moderator",
      joined: Time.now.to_date,
      email: "gtumen@gmail.com",
      password: staff_password,
      password_confirmation: staff_password,
      confirmed_at: Time.now.to_date
  )
  User.create!(
      username: "Breems",
      role: "moderator",
      joined: Time.now.to_date,
      email: 	"seesharpcode@gmail.com",
      password: staff_password,
      password_confirmation: staff_password,
      confirmed_at: Time.now.to_date
  )
  User.create!(
      username: "Nariya",
      role: "moderator",
      joined: Time.now.to_date,
      email: 	"mesaslinger@gmail.com",
      password: staff_password,
      password_confirmation: staff_password,
      confirmed_at: Time.now.to_date
  )

  puts "    #{User.all.count} staff users seeded"
end

def seed_games
  puts "\nSeeding games"

  gameBethesda = Game.create(
      display_name: "Bethesda Games",
      long_name: "Bethesda Games",
      abbr_name: "bg"
  )
  gameSkyrim = Game.create(
      parent_game_id: gameBethesda.id,
      display_name: "Skyrim",
      long_name: "The Elder Scrolls V: Skyrim",
      abbr_name: "sk",
      exe_name: "TESV.exe",
      nexus_name: "skyrim",
      steam_app_ids: "72850"
  )
  gameOblivion = Game.create(
      parent_game_id: gameBethesda.id,
      display_name: "Oblivion",
      long_name: "The Elder Scrolls IV: Oblivion",
      abbr_name: "ob",
      exe_name: "Oblivion.exe",
      nexus_name: "oblivion",
      steam_app_ids: "22330,900883"
  )
  gameFallout4 = Game.create(
      parent_game_id: gameBethesda.id,
      display_name: "Fallout 4",
      long_name: "Fallout 4",
      abbr_name: "fo4",
      exe_name: "Fallout4.exe",
      nexus_name: "fallout4",
      steam_app_ids: "377160"
  )
  gameFalloutNV = Game.create(
      parent_game_id: gameBethesda.id,
      display_name: "Fallout NV",
      long_name: "Fallout: New Vegas",
      abbr_name: "fnv",
      exe_name: "FalloutNV.exe",
      nexus_name: "newvegas",
      steam_app_ids: "22380,2028016"
  )
  gameFallout3 = Game.create(
      parent_game_id: gameBethesda.id,
      display_name: "Fallout 3",
      long_name: "Fallout 3",
      abbr_name: "fo3",
      exe_name: "Fallout3.exe",
      nexus_name: "fallout3",
      steam_app_ids: "22300,22370"
  )

  puts "    #{Game.count} games seeded"
end

def seed_categories
  #==================================================
  # CREATE SUPER-CATEGORIES
  #==================================================

  puts "\nSeeding categories"

  catAudiovisual = Category.create(
      name: "Audiovisual",
      description: "Audiovisual mods are mods which strictly alter the visuals/audio in the game.  This category is often superseded by other categories.",
      priority: 190
  )
  catCharacter = Category.create(
      name: "Character Appearance",
      description: "Mods that modify the appearance of non-player characters in the game or give you additional options for customizing the player character's appearance.",
      priority: 200
  )
  catFixes = Category.create(
      name: "Fixes",
      description: "Fixes are mods that fix issues (bugs) in mods or the vanilla game without adding new content.",
      priority: 20
  )
  catGameplay = Category.create(
      name: "Gameplay",
      description: "Mods classify as Gameplay mods if they alter any game mechanics, pardigms, balance, or events.",
      priority: 110
  )
  catItems = Category.create(
      name: "Items",
      description: "Mods are categorized as Item mods when they add new items to the game.  E.g. new armor, clothing, weapons, food, potions, poisons, ingredients, etc.",
      priority: 140
  )
  catLocations = Category.create(
      name: "Locations",
      description: "Mods which add or modify locations ingame.",
      priority: 100
  )
  catNewChars = Category.create(
      name: "New Characters",
      description: "Mods that add new non-playable characters to the game.",
      priority: 130
  )
  catResources = Category.create(
      name: "Resources",
      description: "These aren't necessarily mods, but they can be.  These are files which are resources to be used by other modders or mod-users.",
      priority: 30
  )
  catUtilities = Category.create(
      name: "Utilities",
      description: "These also aren't necessarily mods, but they can be.  These are tools to aid in the creation and management of mods and mod-related assets.",
      priority: 240
  )

  puts "    #{Category.count} super-categories seeded"


  #==================================================
  # CREATE SUB-CATEGORIES
  #==================================================

  # Audiovisual sub-categories
  Category.create(
      name: "Audiovisual - Animations",
      parent_id: catAudiovisual.id,
      description: "Any mod which adds or alters animations.",
      priority: 193
  )
  Category.create(
      name: "Audiovisual - Lighting & Weather",
      parent_id: catAudiovisual.id,
      description: "Any mod which alters lighting or weather.",
      priority: 194
  )
  catModelsAndTextures = Category.create(
      name: "Audiovisual - Models & Textures",
      parent_id: catAudiovisual.id,
      description: "Any mod which provides modified models/textures without introducing new items, excluding character mods.",
      priority: 191
  )
  Category.create(
      name: "Audiovisual - Post-processing",
      parent_id: catAudiovisual.id,
      description: "Any mod which provides a post-processing preset, e.g. ENB or SweetFX.",
      priority: 192
  )
  Category.create(
      name: "Audiovisual - Sounds & Music",
      parent_id: catAudiovisual.id,
      description: "Any mod which alters or adds sounds or music to the game.",
      priority: 195
  )

  # Character Appearance sub-categories
  Category.create(
      name: "Character Appearance - Face Parts",
      parent_id: catCharacter.id,
      description: "Mods that add new face parts.  E.g. Hairs, beards, brows, eyes, and noses.",
      priority: 201
  )
  Category.create(
      name: "Character Appearance - NPC Overhauls",
      parent_id: catCharacter.id,
      description: "Mods that overhaul NPCs with different faces/outfits.",
      priority: 203
  )
  Category.create(
      name: "Character Appearance - Overlays",
      parent_id: catCharacter.id,
      description: "Mods that add new overlays for characters.  That is, warpaints, tattoos, freckles, tanlines, pimples, chest hair, etc.",
      priority: 202
  )

  # Fixes sub-categories
  Category.create(
      name: "Fixes - Patches",
      parent_id: catFixes.id,
      description: "A fix to make mods compatible with each other, or to carry the changes from one mod into another.",
      priority: 22
  )
  Category.create(
      name: "Fixes - Stability & Performance",
      parent_id: catFixes.id,
      description: "A fix that specifically increases game stability or performance.",
      priority: 21
  )

  # Gameplay sub-categories
  catClassesAndRaces = Category.create(
      name: "Gameplay - Classes and Races",
      parent_id: catGameplay.id,
      description: "Mods that add or alter character classes or races.",
      priority: 115
  )
  Category.create(
      name: "Gameplay - Combat",
      parent_id: catGameplay.id,
      description: "Mods which alter combat, or enemy strength in general.",
      priority: 114
  )
  Category.create(
      name: "Gameplay - Crafting",
      parent_id: catGameplay.id,
      description: "Any mod which modifies the alchemy, enchanting, or smithing systems in the game.  Also includes mods which modify other crafting systems or add new crafting systems.",
      priority: 116
  )
  Category.create(
      name: "Gameplay - Economy & Balance",
      parent_id: catGameplay.id,
      description: "Mods which alter the economy of the game - viz., the acquisition of items and currency.  E.g. modifications to merchants or leveled loot.  Also includes mods which rebalance items, e.g. their weight, gold value, and armor rating/damage.",
      priority: 120
  )
  catFactions = Category.create(
      name: "Gameplay - Factions",
      parent_id: catGameplay.id,
      description: "Mods which alter existing factions and faction quest lines or add new ones.",
      priority: 117
  )
  catImmersionAndRolePlaying = Category.create(
      name: "Gameplay - Immersion & Role-playing",
      parent_id: catGameplay.id,
      description: "Mods which exist specifically to increase the player's immersion in the game world, or to aid in role-playing.",
      priority: 119
  )
  catMagic = Category.create(
      name: "Gameplay - Magic",
      parent_id: catGameplay.id,
      description: "Mods which add new spells, or magic-based mechanics to the game.  Note: Mods that only alter magic-related perk trees should go into Gameplay - Skills & Perks.",
      priority: 112
  )
  catQuests = Category.create(
      name: "Gameplay - Quests",
      parent_id: catGameplay.id,
      description: "Mods which add or alter quests in the game.",
      priority: 118
  )
  catSkillsAndPerks = Category.create(
      name: "Gameplay - Skills & Perks",
      parent_id: catGameplay.id,
      description: "Mods which modify skills or perks in the game, or add new ones.",
      priority: 111
  )
  Category.create(
      name: "Gameplay - Stealth",
      parent_id: catGameplay.id,
      description: "Mods which modify the mechanics of detection, pickpocketing, or lockpicking.  Also includes mods which add new stealth-based mechanics.",
      priority: 113
  )
  Category.create(
      name: "Gameplay - User Interface",
      parent_id: catGameplay.id,
      description: "Mods which alter or add to the main user interface ingame.",
      priority: 40
  )

  # Items sub-categories
  Category.create(
      name: "Items - Armor, Clothing, & Accessories",
      parent_id: catItems.id,
      description: "Mods that add items that can be worn in the major biped slots.  This includes armor, clothing, jewelry, cloaks, bags, etc.",
      priority: 141
  )
  Category.create(
      name: "Items - Ingestibles",
      parent_id: catItems.id,
      description: "Mods that add items you can eat or drink.  This includes alchemical ingredients.",
      priority: 143
  )
  Category.create(
      name: "Items - Tools & Clutter",
      parent_id: catItems.id,
      description: "Mods that add items that cannot be worn, ingested, or used as a weapon.",
      priority: 144
  )
  Category.create(
      name: "Items - Weapons",
      parent_id: catItems.id,
      description: "Mods that that add sticks you can stab, squish, or shoot people with.",
      priority: 142
  )

  # Locations sub-categories
  catNewDungeons = Category.create(
      name: "Locations - New Dungeons",
      parent_id: catLocations.id,
      description: "Mods which add new areas where you encounter and fight enemies.",
      priority: 104
  )
  catNewLands = Category.create(
      name: "Locations - New Lands",
      parent_id: catLocations.id,
      description: "Mods which add completely new lands to explore.",
      priority: 101
  )
  catNewPlayerHomes = Category.create(
      name: "Locations - New Player Homes",
      parent_id: catLocations.id,
      description: "Mods which add new player homes to the game.  This include all sorts of residences ranging from tree houses to castles.",
      priority: 103
  )
  catNewStructuresAndLandmarks = Category.create(
      name: "Locations - New Structures & Landmarks",
      parent_id: catLocations.id,
      description: "Mods which add new structures or landmarks, e.g. Cities, Towns, Inns, Statues, etc.",
      priority: 102
  )
  catOverhauls = Category.create(
      name: "Locations - Overhauls",
      parent_id: catLocations.id,
      description: "Mods which overhaul or build off of one or more vanilla locations.  E.g. City Overhauls, Player Home Overhauls, etc.",
      priority: 105
  )

  # New Characters sub-categories
  Category.create(
      name: "New Characters - Allies",
      parent_id: catNewChars.id,
      description: "If one or more NPCs added by the mod can be allies of the player character, the mod belongs here.",
      priority: 131
  )
  Category.create(
      name: "New Characters - Enemies",
      parent_id: catNewChars.id,
      description: "Mods that add NPCs that try to bash your head in.  Whether they be dragons or flesh-eating bunnies!",
      priority: 133
  )
  Category.create(
      name: "New Characters - Neutral",
      parent_id: catNewChars.id,
      description: "If most of the NPCs added by the mod don't have a disposition to help or hurt the player, put it here.",
      priority: 132
  )

  # Resources sub-categories
  Category.create(
      name: "Resources - Audiovisual",
      parent_id: catResources.id,
      description: "Models, textures, animations, sounds, and music made available for other modders to freely use as resources for their mods.",
      priority: 190
  )
  Category.create(
      name: "Resources - Frameworks",
      parent_id: catResources.id,
      description: "Frameworks offer functionality for other mods or tools to build off of.  Frameworks often don't change much in the game on their own, but enable other mods to do so.  Some frameworks do change aspects of the game.",
      priority: 30
  )
  Category.create(
      name: "Resources - Guides & Tutorials",
      parent_id: catResources.id,
      description: "Any resource that is a guide or tutorial.",
      priority: 0
  )

  # Utilities sub-categories
  Category.create(
      name: "Utilities - Ingame",
      parent_id: catUtilities.id,
      description: "Any utility that exists ingame/has an ingame interface.",
      priority: 40
  )
  Category.create(
      name: "Utilities - Patchers",
      parent_id: catUtilities.id,
      description: "A utility for generating some kind of patch or mod.  E.g. SkyProc patchers, TES5Edit patchers, etc.",
      priority: 242
  )
  Category.create(
      name: "Utilities - Tools",
      parent_id: catUtilities.id,
      description: "A utility which allows you to create, edit, or manage mod-related files.",
      priority: 241
  )

  puts "    #{Category.where.not(parent_id: nil).count} sub-categories seeded"


  #==================================================
  # CREATE CATEGORY PRIORITIES
  #==================================================

  CategoryPriority.create(
      dominant_id: catItems.id,
      recessive_id: catModelsAndTextures.id,
      description: 'New items often include new models & textures.'
  )
  CategoryPriority.create(
      dominant_id: catCharacter.id,
      recessive_id: catModelsAndTextures.id,
      description: 'Character appearance mods often involve new models & textures.'
  )
  CategoryPriority.create(
      dominant_id: catClassesAndRaces.id,
      recessive_id: catCharacter.id,
      description: 'New races often offer new character appearance options.'
  )
  CategoryPriority.create(
      dominant_id: catGameplay.id,
      recessive_id: catFixes.id,
      description: 'Changing gameplay often involves fixing issues with the base game.'
  )
  CategoryPriority.create(
      dominant_id: catFactions.id,
      recessive_id: catNewChars.id,
      description: 'Faction mods often involve adding new characters.'
  )
  CategoryPriority.create(
      dominant_id: catFactions.id,
      recessive_id: catQuests.id,
      description: 'Faction mods often involve adding or altering quests.'
  )
  CategoryPriority.create(
      dominant_id: catMagic.id,
      recessive_id: catAudiovisual.id,
      description: 'Magic mods which add new spells to the game often adds new visual effects.'
  )
  CategoryPriority.create(
      dominant_id: catMagic.id,
      recessive_id: catSkillsAndPerks.id,
      description: 'Magic mods often modify skill and perk trees.'
  )
  CategoryPriority.create(
      dominant_id: catQuests.id,
      recessive_id: catNewChars.id,
      description: 'New or alterred quests often involve new characters.'
  )
  CategoryPriority.create(
      dominant_id: catQuests.id,
      recessive_id: catImmersionAndRolePlaying.id,
      description: 'New or alterred quests often increase gameplay immersion and offer new role-playing experiences.'
  )
  CategoryPriority.create(
      dominant_id: catNewLands.id,
      recessive_id: catGameplay.id,
      description: 'New lands often offer new gameplay opportunities.'
  )
  CategoryPriority.create(
      dominant_id: catNewLands.id,
      recessive_id: catNewChars.id,
      description: 'New lands often include new characters to interact with.'
  )
  CategoryPriority.create(
      dominant_id: catNewLands.id,
      recessive_id: catItems.id,
      description: 'New lands often include new items.'
  )
  CategoryPriority.create(
      dominant_id: catNewLands.id,
      recessive_id: catAudiovisual.id,
      description: 'New lands often offer new audiovisual experiences.'
  )
  CategoryPriority.create(
      dominant_id: catNewDungeons.id,
      recessive_id: catNewChars.id,
      description: 'New dungeons often include new characters.'
  )
  CategoryPriority.create(
      dominant_id: catNewStructuresAndLandmarks.id,
      recessive_id: catNewChars.id,
      description: 'New structures and landmarks often include new characters.'
  )
  CategoryPriority.create(
      dominant_id: catOverhauls.id,
      recessive_id: catAudiovisual.id,
      description: 'Location overhauls often involve new models & textures.'
  )

  puts "    #{CategoryPriority.count} category priorities seeded"

  #==================================================
  # CREATE REVIEW SECTIONS
  #==================================================

  puts "\nSeeding review sections"

  ### Audiovisual ###
  ReviewSection.create(
      category_id: catAudiovisual.id,
      name: "Aesthetics",
      prompt: "Does the mod look/sound good?  Are the assets high quality?",
      default: true
  )
  ReviewSection.create(
      category_id: catAudiovisual.id,
      name: "Consistency",
      prompt: "Does the mod fit in your game?  Does it improve your gameplay experience?",
      default: true
  )
  ReviewSection.create(
      category_id: catAudiovisual.id,
      name: "Performance",
      prompt: "Does the mod cause stuttering or a large reduction in average FPS?  Keep the performance of other mods which do similar things in mind.",
      default: true
  )
  ReviewSection.create(
      category_id: catAudiovisual.id,
      name: "Enjoyment",
      prompt: "Do you enjoy using the mod?  What do you enjoy about it?",
      default: true
  )
  ### Character Appearance ###
  ReviewSection.create(
      category_id: catCharacter.id,
      name: "Aesthetics",
      prompt: "Does the mod look good?  Are the textures and models high quality?",
      default: true
  )
  ReviewSection.create(
      category_id: catCharacter.id,
      name: "Consistency",
      prompt: "Does the mod fit in your game?  Does it improve your gameplay experience?",
      default: true
  )
  ReviewSection.create(
      category_id: catCharacter.id,
      name: "Performance",
      prompt: "Does the mod cause stuttering or a large reduction in average FPS?  Keep the performance of other mods which do similar things in mind."
  )
  ReviewSection.create(
      category_id: catCharacter.id,
      name: "Enjoyment",
      prompt: "Do you enjoy using the mod?  What do you enjoy about it?",
      default: true
  )
  ### Fixes ###
  ReviewSection.create(
      category_id: catFixes.id,
      name: "Consistency",
      prompt: "Does the fix retain the spirit and features of the content it targets?",
      default: true
  )
  ReviewSection.create(
      category_id: catFixes.id,
      name: "Functionality",
      prompt: "Does the fix resolve all of the issues with the content it targets, and does it work?",
      default: true
  )
  ### Gameplay ###
  ReviewSection.create(
      category_id: catGameplay.id,
      name: "Aesthetics",
      prompt: "Does the mod look/sound good?  Are the assets high quality?"
  )
  ReviewSection.create(
      category_id: catGameplay.id,
      name: "Consistency",
      prompt: "Does the mod fit in your game?  Does the mod improve your gameplay experience?  Is the mod balanced?",
      default: true
  )
  ReviewSection.create(
      category_id: catGameplay.id,
      name: "Concept",
      prompt: "Do you like the idea behind the mod?  Is the idea original or unique?"
  )
  ReviewSection.create(
      category_id: catGameplay.id,
      name: "Functionality",
      prompt: "Does the mod provide valuable or unique functionality?  Does it do what it's supposed to do, and does it do it well?",
      default: true
  )
  ReviewSection.create(
      category_id: catGameplay.id,
      name: "Enjoyment",
      prompt: "Do you enjoy using the mod?  What do you enjoy about it?",
      default: true
  )
# FOR QUEST MODS
  ReviewSection.create(
      category_id: catQuests.id,
      name: "Writing",
      prompt: "Is the story interesting and engaging? Does the dialogue fit the characters? Are the characters interesting?",
      default: true
  )
### Items ###
  ReviewSection.create(
      category_id: catItems.id,
      name: "Aesthetics",
      prompt: "Does the mod look/sound good?  Are the assets high quality?",
      default: true
  )
  ReviewSection.create(
      category_id: catItems.id,
      name: "Consistency",
      prompt: "Do the items fit in your game?  Are they balanced?  Is acquiring the items too easy or too difficult?",
      default: true
  )
  ReviewSection.create(
      category_id: catItems.id,
      name: "Concept",
      prompt: "Do you like the idea behind the mod?  Is the idea original or unique?"
  )
  ReviewSection.create(
      category_id: catItems.id,
      name: "Enjoyment",
      prompt: "Do you enjoy using the mod?  What do you enjoy about it?",
      default: true
  )
### Locations ###
  ReviewSection.create(
      category_id: catLocations.id,
      name: "Aesthetics",
      prompt: "Does the Location look good?  Is it designed well and are the textures/models high quality?  Does the interior design look good?  Are there unique/custom visuals which make it stand out?",
      default: true
  )
  ReviewSection.create(
      category_id: catLocations.id,
      name: "Performance",
      prompt: "Does the mod cause stuttering or a large reduction in average FPS?  Keep the performance of other mods which do similar things in mind."
  )
  ReviewSection.create(
      category_id: catLocations.id,
      name: "Consistency",
      prompt: "Does the location fit in your game?  Does it improve your gameplay experience?",
      default: true
  )
  ReviewSection.create(
      category_id: catLocations.id,
      name: "Concept",
      prompt: "Do you like the idea behind the mod?  Is the idea original or unique?"
  )
  ReviewSection.create(
      category_id: catLocations.id,
      name: "Writing",
      prompt: "Is the story interesting and engaging? Does the dialogue fit the characters? Are the characters interesting?",
      default: true
  )
  ReviewSection.create(
      category_id: catLocations.id,
      name: "Voice Acting",
      prompt: "Is the recording decent quality? Do the voice actors do a good job of embodying their characters?"
  )
  ReviewSection.create(
      category_id: catLocations.id,
      name: "Character Behavior",
      prompt: "Do the characters interact with their environment?  Is their behavior realistic?"
  )
  ReviewSection.create(
      category_id: catLocations.id,
      name: "Enjoyment",
      prompt: "Do you enjoy using the mod?  What do you enjoy about it?",
      default: true
  )
# FOR NEW LANDS MODS
  ReviewSection.create(
      category_id: catNewLands.id,
      name: "New Content",
      prompt: "What is the quality of new content added by the mod, such as new items, spells or skills?",
      default: true
  )
# FOR PLAYER HOME MODS
  ReviewSection.create(
      category_id: catNewPlayerHomes.id,
      name: "Features",
      prompt: "Does the player home fit your character's needs?  Are you happy with what it offers?",
      default: true
  )
### New Characters ###
  ReviewSection.create(
      category_id: catNewChars.id,
      name: "Aesthetics",
      prompt: "Do the characters look good?  Do they offer unique aesthetics which help them stand out?",
      default: true
  )
  ReviewSection.create(
      category_id: catNewChars.id,
      name: "Character Behavior",
      prompt: "Do the characters interact with their environment?  Is their behavior realistic?",
      default: true
  )
  ReviewSection.create(
      category_id: catNewChars.id,
      name: "Consistency",
      prompt: "Do the characters fit in your game?  Do they improve your gameplay experience?",
      default: true
  )
  ReviewSection.create(
      category_id: catNewChars.id,
      name: "Concept",
      prompt: "Do you like the idea behind the mod?  Is the idea original or unique?"
  )
  ReviewSection.create(
      category_id: catNewChars.id,
      name: "Enjoyment",
      prompt: "Do you enjoy using the mod?  What do you enjoy about it?",
      default: true
  )
  ReviewSection.create(
      category_id: catNewChars.id,
      name: "Voice Acting",
      prompt: "Is the recording decent quality? Do the voice actors do a good job of embodying their characters?"
  )
  ReviewSection.create(
      category_id: catNewChars.id,
      name: "Writing",
      prompt: "Does the dialogue fit the characters? Are the characters interesting?  Do the characters have a good backstory?",
      default: true
  )
### Resources ###
  ReviewSection.create(
      category_id: catResources.id,
      name: "Aesthetics",
      prompt: "Are any provided textures/audio files/models high quality and appealing?  If a GUI is provided, is it intuitive and clean?",
      default: true
  )
  ReviewSection.create(
      category_id: catResources.id,
      name: "Functionality",
      prompt: "Does the resource provide valuable functionality, or save you time?",
      default: true
  )
  ReviewSection.create(
      category_id: catResources.id,
      name: "Usability",
      prompt: "Is it easy to use the resource?  Is the provided documentation sufficient?",
      default: true
  )
  ### Utilities ###
  ReviewSection.create(
      category_id: catUtilities.id,
      name: "Functionality",
      prompt: "Does the utility provide valuable or unique functionality?  Does it do what it's supposed to do, and does it do it well?",
      default: true
  )
  ReviewSection.create(
      category_id: catUtilities.id,
      name: "Usability",
      prompt: "Is the utility intuitive and easy to use?  Are the learning resources sufficient?  Does using the utility get easier once you've learned the basics?",
      default: true
  )

  puts "    #{ReviewSection.count} review sections seeded"
end

def seed_quotes
  puts "\nSeeding quotes"

  # get helper variables
  gameSkyrim = Game.find_by(display_name: "Skyrim")

  Quote.create(
      game_id: gameSkyrim.id,
      text: "Let me guess, someone stole your sweetroll?",
      label: "Help"
  )
  Quote.create(
      game_id: gameSkyrim.id,
      text: "My cousin is out fighting dragons. And what do I get? Guard duty.",
      label: "Help"
  )
  Quote.create(
      game_id: gameSkyrim.id,
      text: "Would you like a bow that shoots rainbows too? Or perhaps a quiver that dispenses beer?",
      label: "Help"
  )
  Quote.create(
      game_id: gameSkyrim.id,
      text: "The butler did it! Or is it the advisor? Whoever that man behind the throne was.",
      label: "Help"
  )
  Quote.create(
      game_id: gameSkyrim.id,
      text: "Cheese! For everyone!",
      label: "Help"
  )
  Quote.create(
      game_id: gameSkyrim.id,
      text: "Murder, banditry, assault, theft, and lollygagging.",
      label: "Reported"
  )
  Quote.create(
      game_id: gameSkyrim.id,
      text: "I've been hunting and fishing in these parts for years.",
      label: "Random"
  )
  Quote.create(
      game_id: gameSkyrim.id,
      text: "My ancestors are smiling at me imperial, can you say the same?",
      label: "Random"
  )
  Quote.create(
      game_id: gameSkyrim.id,
      text: "I sell fruits and vegetables with my mother, It's fun most days but hard work.",
      label: "Random"
  )
  Quote.create(
      game_id: gameSkyrim.id,
      text: "I used to be an adventurer like you, then I took an arrow to the knee.",
      label: "Random"
  )
  Quote.create(
      game_id: gameSkyrim.id,
      text: "You have come! You have come to hear the word of Talos!",
      label: "Random"
  )
  Quote.create(
      game_id: gameSkyrim.id,
      text: "The Imperials silence us because they fear us! They are cowards! Cowards and fools who have forgotten the truth!",
      label: "Random"
  )
  Quote.create(
      game_id: gameSkyrim.id,
      text: "The truth, child of Talos, is that the Dragon's children have come! To purge the world in fire and righteousness!",
      label: "Random"
  )
  Quote.create(
      game_id: gameSkyrim.id,
      text: "DID YOU KNOW SOME VEGETABLES GROW FASTER IN COLD WEATHER?",
      label: "Random"
  )
  Quote.create(
      game_id: gameSkyrim.id,
      text: "Do you see those warriors from Hammerfell? They've got curved swords. Curved. Swords.",
      label: "Random"
  )
  Quote.create(
      game_id: gameSkyrim.id,
      text: "You are taking us somewhere warm, I trust?",
      label: "Random"
  )
  Quote.create(
      game_id: gameSkyrim.id,
      text: "You'll make a fine rug, cat!",
      label: "Random"
  )
  Quote.create(
      game_id: gameSkyrim.id,
      text: "M'aiq wishes you well.",
      label: "Random"
  )
  Quote.create(
      game_id: gameSkyrim.id,
      text: "M'aiq knows much, and tells some. M'aiq knows many things others do not.",
      label: "Random"
  )
  Quote.create(
      game_id: gameSkyrim.id,
      text: "What does this mean, to combine magic? Magic plus magic is still magic.",
      label: "Random"
  )
  Quote.create(
      game_id: gameSkyrim.id,
      text: "Dragons were never gone. They were just invisible and very, very quiet.",
      label: "Random"
  )
  Quote.create(
      game_id: gameSkyrim.id,
      text: "Werebears? Where? Bears? Men that are bears?",
      label: "Random"
  )
  Quote.create(
      game_id: gameSkyrim.id,
      text: "The people of Skyrim are more open-minded about certain things than people in other places.",
      label: "Random"
  )
  Quote.create(
      game_id: gameSkyrim.id,
      text: "Skyrim was once the land of many butterflies. Now, not so much.",
      label: "Random"
  )
  Quote.create(
      game_id: gameSkyrim.id,
      text: "I'll carve you into pieces!",
      label: "Random"
  )
  Quote.create(
      game_id: gameSkyrim.id,
      text: "You know, I was there for that whole sordid affair.  Marvelous time!  Butterflies, blood, a Fox, a severed head,  HOHO!  Oh, and the cheese!  To die for.",
      label: "Random"
  )
  Quote.create(
      game_id: gameSkyrim.id,
      text: "Inkpot. Stone. Bucket. Book. Knife.",
      label: "Random"
  )
  Quote.create(
      game_id: gameSkyrim.id,
      text: "I wonder what's up there.  Huu huu huu.  Big Dipper.  Little Dipper.  Atmosphere.  Black Holes.  Dragons!  No, no, no dragons.  Just space.",
      label: "Random"
  )
  Quote.create(
      game_id: gameSkyrim.id,
      text: "Hey, hey, level up speech, talk people into going to space.  Huu huu.  Plenty of room.",
      label: "Random"
  )
  Quote.create(
      game_id: gameSkyrim.id,
      text: "Skyrim belongs to the Nords!",
      label: "Low Reputation"
  )
  Quote.create(
      game_id: gameSkyrim.id,
      text: "Do you get to the cloud district very often?  Oh what am I saying.  Of course you don't.",
      label: "Low Reputation"
  )
  Quote.create(
      game_id: gameSkyrim.id,
      text: "Talos the mighty! Talos the unerring! Talos the unassailable! To you we give praise!",
      label: "High Reputation"
  )
  Quote.create(
      game_id: gameSkyrim.id,
      text: "Do you get to the cloud district very often?  Oh what am I saying.  Of course you do.",
      label: "High Reputation"
  )

  puts "    #{Quote.count} quotes seeded"
end

def seed_user_titles
  puts "\nSeeding user titles"

  # get helper variables
  gameSkyrim = Game.find_by(display_name: "Skyrim")

  UserTitle.create(
      game_id: gameSkyrim.id,
      title: "Slaughterfish",
      rep_required: -9999999
  )
  UserTitle.create(
      game_id: gameSkyrim.id,
      title: "Skeever",
      rep_required: -40
  )
  UserTitle.create(
      game_id: gameSkyrim.id,
      title: "Mudcrab",
      rep_required: -20
  )
  UserTitle.create(
      game_id: gameSkyrim.id,
      title: "Draugr",
      rep_required: -10
  )
  UserTitle.create(
      game_id: gameSkyrim.id,
      title: "Prisoner",
      rep_required: 0
  )
  UserTitle.create(
      game_id: gameSkyrim.id,
      title: "Beggar",
      rep_required: 10
  )
  UserTitle.create(
      game_id: gameSkyrim.id,
      title: "Milk Drinker",
      rep_required: 20
  )
  UserTitle.create(
      game_id: gameSkyrim.id,
      title: "Rogue",
      rep_required: 40
  )
  UserTitle.create(
      game_id: gameSkyrim.id,
      title: "Bard",
      rep_required: 80
  )
  UserTitle.create(
      game_id: gameSkyrim.id,
      title: "Adventurer",
      rep_required: 160
  )
  UserTitle.create(
      game_id: gameSkyrim.id,
      title: "Thane",
      rep_required: 320
  )
  UserTitle.create(
      game_id: gameSkyrim.id,
      title: "Dragonborn",
      rep_required: 640
  )

  puts "    #{UserTitle.count} user titles seeded"
end

def seed_record_groups

  puts "\nSeeding record groups"

  # get helper variables
  gameSkyrim = Game.find_by(display_name: "Skyrim")

  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'ACHR',
      name: 'Placed NPC',
      child_group: true
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'ACTI',
      name: 'Activator',
      child_group: false
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'TACT',
      name: 'Talking Activator',
      child_group: false
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'ALCH',
      name: 'Ingestible',
      child_group: false
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'AMMO',
      name: 'Ammunition',
      child_group: false
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'ANIO',
      name: 'Animated Object',
      child_group: false
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'ARMO',
      name: 'Armor',
      child_group: false
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'ARMA',
      name: 'Armor Addon',
      child_group: false
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'BOOK',
      name: 'Book',
      child_group: false
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'PARW',
      name: 'Placed Arrow',
      child_group: true
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'PBAR',
      name: 'Placed Barrier',
      child_group: true
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'PBEA',
      name: 'Placed Beam',
      child_group: true
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'PCON',
      name: 'Placed Cone/Voice',
      child_group: true
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'PFLA',
      name: 'Placed Flame',
      child_group: true
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'PGRE',
      name: 'Placed Projectile',
      child_group: true
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'PHZD',
      name: 'Placed Hazard',
      child_group: true
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'PMIS',
      name: 'Placed Missile',
      child_group: true
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'CELL',
      name: 'Cell',
      child_group: false
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'CLAS',
      name: 'Class',
      child_group: false
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'CLMT',
      name: 'Climate',
      child_group: false
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'SPGD',
      name: 'Shader Particle Geometry',
      child_group: false
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'RFCT',
      name: 'Visual Effect',
      child_group: false
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'CONT',
      name: 'Container',
      child_group: false
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'CSTY',
      name: 'Combat Style',
      child_group: false
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'DIAL',
      name: 'Dialog Topic',
      child_group: false
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'DOOR',
      name: 'Door',
      child_group: false
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'EFSH',
      name: 'Effect Shader',
      child_group: false
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'ENCH',
      name: 'Object Effect',
      child_group: false
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'EYES',
      name: 'Eyes',
      child_group: false
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'FACT',
      name: 'Faction',
      child_group: false
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'FURN',
      name: 'Furniture',
      child_group: false
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'GLOB',
      name: 'Global',
      child_group: false
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'GMST',
      name: 'Game Setting',
      child_group: false
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'KYWD',
      name: 'Keyword',
      child_group: false
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'LCRT',
      name: 'Location Reference Type',
      child_group: false
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'AACT',
      name: 'Action',
      child_group: false
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'TXST',
      name: 'Texture Set',
      child_group: false
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'HDPT',
      name: 'Head Part',
      child_group: false
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'ASPC',
      name: 'Acoustic Space',
      child_group: false
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'MSTT',
      name: 'Moveable Static',
      child_group: false
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'IDLM',
      name: 'Idle Marker',
      child_group: false
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'PROJ',
      name: 'Projectile',
      child_group: false
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'HAZD',
      name: 'Hazard',
      child_group: false
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'SLGM',
      name: 'Soul Gem',
      child_group: false
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'NAVI',
      name: 'Navigation Mesh Info Map',
      child_group: false
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'NAVM',
      name: 'Navigation Mesh',
      child_group: true
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'EXPL',
      name: 'Explosion',
      child_group: false
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'DEBR',
      name: 'Debris',
      child_group: false
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'IMGS',
      name: 'Image Space',
      child_group: false
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'IMAD',
      name: 'Image Space Adapter',
      child_group: false
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'FLST',
      name: 'FormID List',
      child_group: false
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'PERK',
      name: 'Perk',
      child_group: false
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'BPTD',
      name: 'Body Part Data',
      child_group: false
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'ADDN',
      name: 'Addon Node',
      child_group: false
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'AVIF',
      name: 'Actor Value Information',
      child_group: false
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'CAMS',
      name: 'Camera Shot',
      child_group: false
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'CPTH',
      name: 'Camera Path',
      child_group: false
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'VTYP',
      name: 'Voice Type',
      child_group: false
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'MATT',
      name: 'Material Type',
      child_group: false
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'IPCT',
      name: 'Impact',
      child_group: false
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'IPDS',
      name: 'Impact Data Set',
      child_group: false
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'ECZN',
      name: 'Encounter Zone',
      child_group: false
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'LCTN',
      name: 'Location',
      child_group: false
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'MESG',
      name: 'Message',
      child_group: false
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'DOBJ',
      name: 'Default Object Manager',
      child_group: false
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'LGTM',
      name: 'Lighting Template',
      child_group: false
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'MUSC',
      name: 'Music Type',
      child_group: false
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'FSTP',
      name: 'Footstep',
      child_group: false
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'FSTS',
      name: 'Footstep Set',
      child_group: false
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'SMBN',
      name: 'Story Manager Branch Node',
      child_group: false
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'SMQN',
      name: 'Story Manager Quest Node',
      child_group: false
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'SMEN',
      name: 'Story Manager Event Node',
      child_group: false
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'DLBR',
      name: 'Dialog Branch',
      child_group: false
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'MUST',
      name: 'Music Track',
      child_group: false
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'DLVW',
      name: 'Dialog View',
      child_group: false
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'WOOP',
      name: 'Word of Power',
      child_group: false
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'SHOU',
      name: 'Shout',
      child_group: false
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'EQUP',
      name: 'Equip Type',
      child_group: false
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'RELA',
      name: 'Relationship',
      child_group: false
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'SCEN',
      name: 'Scene',
      child_group: false
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'ASTP',
      name: 'Association Type',
      child_group: false
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'OTFT',
      name: 'Outfit',
      child_group: false
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'ARTO',
      name: 'Art Object',
      child_group: false
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'MATO',
      name: 'Material Object',
      child_group: false
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'MOVT',
      name: 'Movement Type',
      child_group: false
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'SNDR',
      name: 'Sound Descriptor',
      child_group: false
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'DUAL',
      name: 'Dual Cast Data',
      child_group: false
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'SNCT',
      name: 'Sound Category',
      child_group: false
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'SOPM',
      name: 'Sound Output Model',
      child_group: false
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'COLL',
      name: 'Collision Layer',
      child_group: false
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'CLFM',
      name: 'Color',
      child_group: false
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'REVB',
      name: 'Reverb Parameters',
      child_group: false
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'GRAS',
      name: 'Grass',
      child_group: false
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'IDLE',
      name: 'Idle Animation',
      child_group: false
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'INFO',
      name: 'Dialog response',
      child_group: true
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'INGR',
      name: 'Ingredient',
      child_group: false
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'KEYM',
      name: 'Key',
      child_group: false
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'LAND',
      name: 'Landscape',
      child_group: true
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'LIGH',
      name: 'Light',
      child_group: false
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'LSCR',
      name: 'Load Screen',
      child_group: false
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'LTEX',
      name: 'Landscape Texture',
      child_group: false
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'LVLN',
      name: 'Leveled NPC',
      child_group: false
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'LVLI',
      name: 'Leveled Item',
      child_group: false
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'LVSP',
      name: 'Leveled Spell',
      child_group: false
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'MGEF',
      name: 'Magic Effect',
      child_group: false
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'MISC',
      name: 'Misc. Item',
      child_group: false
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'APPA',
      name: 'Alchemical Apparatus',
      child_group: false
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'COBJ',
      name: 'Constructible Object',
      child_group: false
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'NPC_',
      name: 'Non-Player Character (Actor)',
      child_group: false
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'PACK',
      name: 'Package',
      child_group: false
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'QUST',
      name: 'Quest',
      child_group: false
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'RACE',
      name: 'Race',
      child_group: false
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'REFR',
      name: 'Placed Object',
      child_group: true
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'REGN',
      name: 'Region',
      child_group: false
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'SOUN',
      name: 'Sound Marker',
      child_group: false
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'SPEL',
      name: 'Spell',
      child_group: false
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'SCRL',
      name: 'Scroll',
      child_group: false
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'STAT',
      name: 'Static',
      child_group: false
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'TES4',
      name: 'Main File Header',
      child_group: true
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'TREE',
      name: 'Tree',
      child_group: false
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'FLOR',
      name: 'Flora',
      child_group: false
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'WATR',
      name: 'Water',
      child_group: false
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'WEAP',
      name: 'Weapon',
      child_group: false
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'WRLD',
      name: 'Worldspace',
      child_group: false
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'WTHR',
      name: 'Weather',
      child_group: false
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'CLDC',
      name: 'CLDC',
      child_group: false
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'HAIR',
      name: 'HAIR',
      child_group: false
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'PWAT',
      name: 'PWAT',
      child_group: false
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'RGDL',
      name: 'RGDL',
      child_group: false
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'SCOL',
      name: 'SCOL',
      child_group: false
  )
  RecordGroup.create(
      game_id: gameSkyrim.id,
      signature: 'SCPT',
      name: 'SCPT',
      child_group: false
  )

  puts "    #{RecordGroup.count} record groups seeded"
end

def seed_official_content
  puts "\nSeeding official content"

  # get helper variables
  mator = User.find_by(username: "Mator")
  gameSkyrim = Game.find_by(display_name: "Skyrim")

  modSkyrim = Mod.create!(
      name: "Skyrim",
      authors: "Bethesda",
      submitted_by: mator.id,
      is_official: true,
      game_id: gameSkyrim.id,
      released: DateTime.new(2011, 11, 11),
      updated: DateTime.new(2013, 3, 20),
      custom_sources_attributes: [{
          label: "Steam Store",
          url: "http://store.steampowered.com/app/72850/"
      }]
  )
  # Create config files
  create_config_file(modSkyrim, "Skyrim.ini", "{{MyGamesFolder}}")
  create_config_file(modSkyrim, "SkyrimPrefs.ini", "{{MyGamesFolder}}")
  # Create plugins
  create_plugin(modSkyrim, "Skyrim.esm.json")
  create_plugin(modSkyrim, "Update.esm.json")
  modSkyrim.update_lazy_counters

  modDawnguard = Mod.create!(
      name: "Dawnguard",
      authors: "Bethesda",
      submitted_by: mator.id,
      is_official: true,
      game_id: gameSkyrim.id,
      primary_category_id: Category.find_by(name: "Locations").id,
      secondary_category_id: Category.find_by(name: "Gameplay - Factions").id,
      released: DateTime.new(2012, 8, 2),
      custom_sources_attributes: [{
          label: "Steam Store",
          url: "http://store.steampowered.com/app/211720/"
      }],
      tag_names: ["Vampires", "Dawnguard", "Werewolves", "Soul Cairn", "Dragonbone"]
  )
  # Create plugins
  create_plugin(modDawnguard, "Dawnguard.esm.json")
  modDawnguard.update_lazy_counters

  modHearthfire = Mod.create!(
      name: "Hearthfire",
      authors: "Bethesda",
      submitted_by: mator.id,
      is_official: true,
      game_id: gameSkyrim.id,
      primary_category_id: Category.find_by(name: "Locations - New Player Homes").id,
      secondary_category_id: Category.find_by(name: "Gameplay - Immersion & Role-playing").id,
      released: DateTime.new(2012, 10, 4),
      custom_sources_attributes: [{
          label: "Steam Store",
          url: "http://store.steampowered.com/app/220760/"
      }],
      tag_names: ["Building", "Family", "Marriage", "Adoption"]
  )
  # Create plugins
  create_plugin(modHearthfire, "HearthFires.esm.json")
  modHearthfire.update_lazy_counters

  modDragonborn = Mod.create!(
      name: "Dragonborn",
      authors: "Bethesda",
      submitted_by: mator.id,
      is_official: true,
      game_id: gameSkyrim.id,
      primary_category_id: Category.find_by(name: "Locations - New Lands").id,
      released: DateTime.new(2013, 2, 5),
      custom_sources_attributes: [{
          label: "Steam Store",
          url: "http://store.steampowered.com/app/211720/"
      }],
      tag_names: ["Solstheim", "Apocrypha", "Hermaeus Mora", "Shouts", "Stahlrim", "Nordic", "Bonemold", "Chitin"]
  )
  # Create plugins
  create_plugin(modDragonborn, "Dragonborn.esm.json")
  modDragonborn.update_lazy_counters

  modHighRes = Mod.create!(
      name: "High Resolution Texture Pack",
      authors: "Bethesda",
      submitted_by: mator.id,
      is_official: true,
      game_id: gameSkyrim.id,
      primary_category_id: Category.find_by(name: "Audiovisual - Models & Textures").id,
      released: DateTime.new(2012, 2, 7),
      custom_sources_attributes: [{
          label: "Steam Store",
          url: "http://store.steampowered.com/app/202485/"
      }],
      tag_names: ["1K", "Armor", "Weapons", "Architecture", "Actors", "Dungeons", "Terrain", "Clutter"]
  )
  # Create plugins
  create_plugin(modHighRes, "HighResTexturePack01.esp.json")
  create_plugin(modHighRes, "HighResTexturePack02.esp.json")
  create_plugin(modHighRes, "HighResTexturePack03.esp.json")
  modHighRes.update_lazy_counters

  puts "    #{Mod.count} official mods seeded"
  puts "    #{Plugin.count} official plugins seeded"
end
