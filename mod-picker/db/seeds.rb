# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

#==================================================
# CLEAR CATEGORIES TABLE
#==================================================

connection = ActiveRecord::Base.connection()
connection.execute("DELETE FROM categories WHERE parent_id IS NOT NULL;")
connection.execute("DELETE FROM categories WHERE parent_id IS NULL;")
connection.execute("ALTER TABLE categories AUTO_INCREMENT = 0;")

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