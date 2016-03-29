def seed_static_records
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
  # CREATE QUOTES
  #==================================================

  puts "\nSeeding quotes"

  Quote.create(
    game_id: gameSkyrim.id,
    text: "Let me guess, someone stole your sweetroll?",
    label: "help"
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
      text: "You’ll make a fine rug, cat!",
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
      text: "I’ll carve you into pieces!",
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

  #==================================================
  # CREATE RECORD GROUPS
  #==================================================

  puts "\nSeeding record groups"

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
