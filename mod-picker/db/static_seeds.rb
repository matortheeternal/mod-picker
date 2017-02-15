def create_plugin(mod_option, dump_filename)
  file = File.read(Rails.root.join("db", "plugins", dump_filename))
  hash = JSON.parse(file).with_indifferent_access
  hash[:game_id] = mod_option.mod.game_id
  mod_option.plugins.create(hash)
end

def create_option(mod)
  mod.mod_options.create({
      display_name: mod.name,
      name: mod.name,
      default: true
  })
end

def create_tags(user, mod, tags)
  builder = ModBuilder.new(user, {id: mod.id, tag_names: tags})
  builder.update
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
      esm_name: "Skyrim.esm",
      nexus_name: "skyrim",
      steam_app_ids: "72850"
  )
  gameOblivion = Game.create(
      parent_game_id: gameBethesda.id,
      display_name: "Oblivion",
      long_name: "The Elder Scrolls IV: Oblivion",
      abbr_name: "ob",
      exe_name: "Oblivion.exe",
      esm_name: "Oblivion.esm",
      nexus_name: "oblivion",
      steam_app_ids: "22330,900883"
  )
  gameFallout4 = Game.create(
      parent_game_id: gameBethesda.id,
      display_name: "Fallout 4",
      long_name: "Fallout 4",
      abbr_name: "fo4",
      exe_name: "Fallout4.exe",
      esm_name: "Fallout4.esm",
      nexus_name: "fallout4",
      steam_app_ids: "377160"
  )
  gameFalloutNV = Game.create(
      parent_game_id: gameBethesda.id,
      display_name: "Fallout NV",
      long_name: "Fallout: New Vegas",
      abbr_name: "fnv",
      exe_name: "FalloutNV.exe",
      esm_name: "FalloutNV.esm",
      nexus_name: "newvegas",
      steam_app_ids: "22380,2028016"
  )
  gameFallout3 = Game.create(
      parent_game_id: gameBethesda.id,
      display_name: "Fallout 3",
      long_name: "Fallout 3",
      abbr_name: "fo3",
      exe_name: "Fallout3.exe",
      esm_name: "Fallout3.esm",
      nexus_name: "fallout3",
      steam_app_ids: "22300,22370"
  )
  gameSkyrimSE = Game.create(
      parent_game_id: gameBethesda.id,
      display_name: "Skyrim SE",
      long_name: "Skyrim: Special Edition",
      abbr_name: "sse",
      exe_name: "SkyrimSE.exe",
      esm_name: "Skyrim.esm",
      nexus_name: "skyrimspecialedition",
      steam_app_ids: "489830"
  )

  puts "    #{Game.count} games seeded"
end

def seed_licenses
  puts "\nSeeding licenses"
  terms = {
      unknown: 0,
      no: 1,
      yes: 2,
      with_permission: 3
  }

  License.create(
      name: "None",
      license_type: "copyright",
      wikipedia_page: "Copyright",
      clauses: 0,
      code: true,
      assets: true,
      commercial: terms[:with_permission],
      redistribution: terms[:with_permission],
      modification: terms[:with_permission],
      private_use: terms[:with_permission],
      include: terms[:no],
      description: "Without a license the materials are copyrighted by default.  People can view the materials, but they have no legal right to use them.  To use the materials they must contact the author directly and ask for permission.  That includes people using the mod in their game. Generally speaking you should never release a mod without an explicit license."
  )
  License.create(
      name: "Public Domain",
      acronym: "PD",
      license_type: "permissive",
      wikipedia_page: "Public_Domain",
      license_options_attributes: [{
          name: "Creative Commons CC0 1.0 Universal",
          acronym: "CC-0",
          tldr: "creative-commons-cc0-1.0-universal",
          link: "https://creativecommons.org/publicdomain/zero/1.0/"
      }, {
          name: "Unlicense",
          tldr: "unlicense",
          link: "http://unlicense.org/"
      }],
      clauses: 0,
      code: true,
      assets: true,
      credit: terms[:yes],
      commercial: terms[:yes],
      redistribution: terms[:yes],
      modification: terms[:yes],
      private_use: terms[:yes],
      include: terms[:no],
      description: "Releasing something into the public domain involves relinquishing all ownership/copyright over it.  If your materials are in the public domain that means anyone can use them for any purpose whatsoever, including commercial use."
  )
  License.create(
      name: "Do What The F*ck You Want To Public License",
      acronym: "WTFPL",
      license_type: "permissive",
      wikipedia_page: "WTFPL",
      license_options_attributes: [{
          name: "Do What the F*ck You Want To Public License v2",
          tldr: "do-wtf-you-want-to-public-license-v2-(wtfpl-2.0)",
          link: "http://www.wtfpl.net/about/"
      }],
      clauses: 1,
      code: true,
      assets: true,
      credit: terms[:yes],
      commercial: terms[:yes],
      redistribution: terms[:yes],
      modification: terms[:yes],
      private_use: terms[:yes],
      include: terms[:no],
      description: "The WTFPL is almost a public domain grant. It is super-permissive. Basically, do whatever you want.  You still retain ownership."
  )
  License.create(
      name: "GNU General Public License",
      acronym: "GPL",
      license_options_attributes: [{
          name: "GNU General Public License, version 1",
          acronym: "GPLv1",
          link: "https://www.gnu.org/licenses/old-licenses/gpl-1.0.en.html"
      }, {
          name: "GNU General Public License, version 2",
          acronym: "GPLv2",
          tldr: "gnu-general-public-license-v2",
          link: "https://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html"
      }, {
          name: "GNU General Public License, version 3",
          acronym: "GPLv3",
          tldr: "gnu-general-public-license-v3-(gpl-3)",
          link: "https://www.gnu.org/licenses/gpl-3.0.en.html"
      }],
      license_type: "copyleft",
      wikipedia_page: "GNU_General_Public_License",
      clauses: 12,
      code: true,
      assets: false,
      credit: terms[:yes],
      commercial: terms[:yes],
      redistribution: terms[:yes],
      modification: terms[:yes],
      private_use: terms[:yes],
      include: terms[:yes],
      description: "While the GPL allows commercial use it's generally not viable to do so due to other clauses in the license."
  )
  License.create(
      name: "GNU Lesser General Public License",
      acronym: "LGPL",
      license_type: "mostly copyleft",
      wikipedia_page: "GNU_Lesser_General_Public_License",
      license_options_attributes: [{
          name: "GNU Lesser General Public License, version 2.1",
          acronym: "LGPLv2",
          tldr: "gnu-lesser-general-public-license-v2.1-(lgpl-2.1)",
          link: "https://www.gnu.org/licenses/old-licenses/lgpl-2.1.en.html"
      }, {
          name: "GNU Lesser General Public License, version 3",
          acronym: "LGPLv3",
          tldr: "gnu-lesser-general-public-license-v3-(lgpl-3)",
          link: "https://www.gnu.org/licenses/lgpl-3.0.en.html"
      }],
      clauses: 16,
      code: true,
      assets: false,
      credit: terms[:yes],
      commercial: terms[:yes],
      redistribution: terms[:yes],
      modification: terms[:yes],
      private_use: terms[:yes],
      include: terms[:yes],
      description: "This license is mainly applied to libraries. You may copy, distribute and modify the software provided that modifications are described and licensed for free under LGPL. Derivatives works (including modifications or anything statically linked to the library) can only be redistributed under LGPL, but applications that use the library don't have to be."
  )
  License.create(
      name: "MIT License",
      acronym: "MIT",
      license_type: "permissive",
      license_options_attributes: [{
          name: "MIT License",
          tldr: "mit-license",
          link: "https://en.wikipedia.org/wiki/MIT_License"
      }],
      clauses: 2,
      code: true,
      assets: false,
      credit: terms[:yes],
      commercial: terms[:yes],
      redistribution: terms[:yes],
      modification: terms[:yes],
      private_use: terms[:yes],
      include: terms[:yes],
      description: "A short, permissive software license. Basically, you can do whatever you want as long as you include the original copyright and license notice in any copy of the software/source."
  )
  License.create(
      name: "BSD License",
      acronym: "BSD",
      license_type: "permissive",
      license_options_attributes: [{
          name: "BSD License",
          tldr: "bsd-2-clause-license-(freebsd)",
          link: "https://www.freebsd.org/copyright/freebsd-license.html"
      }],
      clauses: 2,
      code: true,
      assets: false,
      credit: terms[:yes],
      commercial: terms[:yes],
      redistribution: terms[:yes],
      modification: terms[:yes],
      private_use: terms[:yes],
      include: terms[:yes],
      description: "The BSD 2-clause license allows you almost unlimited freedom with the software so long as you include the BSD copyright notice in it."
  )
  License.create(
      name: "Apache License",
      acronym: "ASL",
      license_options_attributes: [{
          name: "Apache License 1.0",
          acronym: "Apache-1.0",
          tldr: "apache-license-1.0-(apache-1.0)",
          link: "https://www.apache.org/licenses/LICENSE-1.0"
      }, {
          name: "Apache License 1.1",
          acronym: "Apache-1.1",
          tldr: "apache-license-1.1",
          link: "https://www.apache.org/licenses/LICENSE-1.1"
      }, {
          name: "Apache License 2.0",
          acronym: "Apache-2.0",
          tldr: "apache-license-2.0-(apache-2.0)",
          link: "https://www.apache.org/licenses/LICENSE-2.0"
      }],
      license_type: "permissive",
      wikipedia_page: "Apache_License",
      clauses: 9,
      code: true,
      assets: false,
      credit: terms[:yes],
      commercial: terms[:yes],
      redistribution: terms[:yes],
      modification: terms[:yes],
      private_use: terms[:yes],
      include: terms[:yes],
      description: "You can do what you like with the software, as long as you include the required notices."
  )
  License.create(
      name: "Eclipse Public License",
      acronym: "EPL",
      license_type: "permissive",
      wikipedia_page: "Eclipse_Public_License",
      license_options_attributes: [{
          name: "Eclipse Public License 1.0",
          tldr: "eclipse-public-license-1.0-(epl-1.0)",
          link: "https://www.eclipse.org/legal/epl-v10.html"
      }],
      clauses: 7,
      code: true,
      assets: false,
      credit: terms[:yes],
      commercial: terms[:yes],
      redistribution: terms[:yes],
      modification: terms[:yes],
      private_use: terms[:yes],
      include: terms[:yes],
      description: "This license, made and used by the Eclipse Foundation, is similar to GPL but allows you to link code under the license to proprietary applications. You may also license binaries under a proprietary license, as long as the source code is available under EPL."
  )
  License.create(
      name: "Mozilla Public License",
      acronym: "MPL",
      license_options_attributes: [{
          name: "Mozilla Public License 1.0",
          acronym: "MPL-1.0",
          tldr: "mozilla-public-license-1.0-(mpl-1.0)",
          link: "https://www.mozilla.org/en-US/MPL/"
      }, {
          name: "Mozilla Public License 1.1",
          acronym: "MPL-1.1",
          tldr: "mozilla-public-license-1.1-(mpl-1.1)",
          link: "https://www.mozilla.org/en-US/MPL/1.1/"
      }, {
          name: "Mozilla Public License 2.0",
          acronym: "MPL-2.0",
          tldr: "mozilla-public-license-2.0-(mpl-2)",
          link: "https://www.mozilla.org/en-US/MPL/2.0/"
      }],
      license_type: "weak copyleft",
      wikipedia_page: "Mozilla_Public_License",
      clauses: 13,
      code: true,
      assets: false,
      credit: terms[:yes],
      commercial: terms[:yes],
      redistribution: terms[:yes],
      modification: terms[:yes],
      private_use: terms[:yes],
      include: terms[:yes],
      description: "A copyleft license, though not considered strong copyleft since the license only requires the source code of modified components to be disclosed. Incompatible with GNU GPL (though MPL-2.0 is compatible)."
  )
  License.create(
      name: "Creative Commons Attribution",
      acronym: "CC BY",
      license_type: "copyright",
      license_options_attributes: [{
          name: "Creative Commons BY 4.0",
          tldr: "creative-commons-attribution-4.0-international-(cc-by-4)",
          link: "https://creativecommons.org/licenses/by/4.0/"
      }],
      clauses: 8,
      code: true,
      assets: true,
      credit: terms[:yes],
      commercial: terms[:yes],
      redistribution: terms[:yes],
      modification: terms[:yes],
      private_use: terms[:yes],
      include: terms[:no],
      description: "This creative commons license allows redistribution, derivative works, and commercial use."
  )
  License.create(
      name: "Creative Commons Attribution-NonCommercial",
      acronym: "CC BY-NC",
      license_type: "copyright",
      license_options_attributes: [{
          name: "Creative Commons BY-NC 4.0",
          tldr: "creative-commons-attribution-noncommercial-4.0-international-(cc-by-nc-4.0)",
          link: "https://creativecommons.org/licenses/by-nc/4.0/"
      }],
      clauses: 8,
      code: true,
      assets: true,
      credit: terms[:yes],
      commercial: terms[:no],
      redistribution: terms[:yes],
      modification: terms[:yes],
      private_use: terms[:yes],
      include: terms[:no],
      description: "This creative commons license allows redistribution and derivative works but restricts using the materials for commercial use."
  )
  License.create(
      name: "Creative Commons Attribution-ShareAlike",
      acronym: "CC BY-SA",
      license_type: "copyright",
      license_options_attributes: [{
          name: "Creative Commons BY-SA 4.0",
          tldr: "creative-commons-attribution-sharealike-4.0-international-(cc-by-sa-4.0)",
          link: "https://creativecommons.org/licenses/by-sa/4.0/"
      }],
      clauses: 8,
      code: true,
      assets: true,
      credit: terms[:yes],
      commercial: terms[:yes],
      redistribution: terms[:yes],
      modification: terms[:yes],
      private_use: terms[:yes],
      include: terms[:yes],
      description: "This creative commons license allows redistribution, derivative works, and commercial use.  The license requires people who use your materials to use a similar license (share alike)."
  )
  License.create(
      name: "Creative Commons Attribution-NonCommercial-ShareAlike",
      acronym: "CC BY-NC-SA",
      license_type: "copyright",
      license_options_attributes: [{
          name: "Creative Commons BY-NC-SA 4.0",
          tldr: "creative-commons-attribution-noncommercial-sharealike-4.0-international-(cc-by-nc-sa-4.0)",
          link: "https://creativecommons.org/licenses/by-nc-sa/4.0/"
      }],
      clauses: 8,
      code: true,
      assets: true,
      credit: terms[:yes],
      commercial: terms[:no],
      redistribution: terms[:yes],
      modification: terms[:yes],
      private_use: terms[:yes],
      include: terms[:yes],
      description: "This creative commons license allows redistribution and derivative works but restricts using the materials for commercial use.  The license requires derivative works to use a similar license (share alike)."
  )
  License.create(
      name: "Creative Commons Attribution-NoDerivatives",
      acronym: "CC BY-ND",
      license_type: "copyright",
      license_options_attributes: [{
          name: "Creative Commons BY-ND 4.0",
          tldr: "creative-commons-attribution-noderivatives-4.0-international-(cc-by-nd-4.0)",
          link: "https://creativecommons.org/licenses/by-nd/4.0/",
      }],
      clauses: 8,
      code: true,
      assets: true,

      credit: terms[:yes],
      commercial: terms[:yes],
      redistribution: terms[:yes],
      modification: terms[:no],
      private_use: terms[:yes],
      include: terms[:no],
      description: "This creative commons license allows redistribution and commerical use but restricts the creation of derivative works."
  )
  License.create(
      name: "Creative Commons Attribution-NonCommercial-NoDerivatives",
      acronym: "CC BY-NC-ND",
      license_type: "copyright",
      license_options_attributes: [{
          name: "Creative Commons BY-NC-ND 4.0",
          tldr: "creative-commons-attribution-noncommercial-noderivs-(cc-nc-nd)",
          link: "https://creativecommons.org/licenses/by-nc-nd/4.0/"
      }],
      clauses: 8,
      code: true,
      assets: true,
      credit: terms[:yes],
      commercial: terms[:no],
      redistribution: terms[:yes],
      modification: terms[:no],
      private_use: terms[:yes],
      include: terms[:no],
      description: "This is the most restrictive creative commons license.  The license allows redistribution, but restricts commercial use or derivative works."
  )
  License.create(
      name: "Custom License",
      license_type: "custom",
      license_options_attributes: [{
          name: "Binpress License Generator",
          link: "http://www.binpress.com/license/generator"
      }],
      code: true,
      assets: true,
      description: "Make your own license.  The advantage of making your own license is you can define the terms yourself.  The disadvantage is it becomes a harder for users to determine your permissions at a glance, and creating a strong, legally binding license can be time-consuming or difficult.  It is very important to include a statement releasing liability if you make a custom license!"
  )

  puts "    #{License.count} licenses seeded"
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
      description: "Mods that add new non-playable characters to the game.  This includes animals and creatures, such as dragons, skeletons, bears and fish.",
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
      name: "Gameplay - AI & Combat",
      parent_id: catGameplay.id,
      description: "Mods which alter character behavior, combat mechanics, or enemy strength in general.",
      priority: 114
  )
  Category.create(
      name: "Gameplay - Crafting",
      parent_id: catGameplay.id,
      description: "Any mod which modifies the alchemy, enchanting, or smithing systems in the game.  Also includes mods which modify other crafting systems or add new crafting systems.",
      priority: 116
  )
  Category.create(
      name: "Gameplay - Economy & Item Balance",
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
      description: "Mods that add sticks you can stab, squish, or shoot people with.",
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
      description: 'New or altered quests often involve new characters.'
  )
  CategoryPriority.create(
      dominant_id: catQuests.id,
      recessive_id: catImmersionAndRolePlaying.id,
      description: 'New or altered quests often increase gameplay immersion and offer new role-playing experiences.'
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

def load_record_groups(game, filename)
  file = File.read(Rails.root.join("db", "record_groups", filename))
  json = JSON.parse(file)
  json.each do |item|
    record_group = item.with_indifferent_access
    record_group[:game_id] = game.id
    RecordGroup.create(record_group)
  end
end

def seed_record_groups
  puts "\nSeeding record groups"

  # get helper variables
  gameSkyrim = Game.find_by(display_name: "Skyrim")
  gameSkyrimSE = Game.find_by(display_name: "Skyrim SE")

  load_record_groups(gameSkyrim, "skyrim.json")
  load_record_groups(gameSkyrimSE, "skyrimse.json")

  puts "    #{RecordGroup.count} record groups seeded"
end

def seed_skyrim_official_content(submitter)
  gameSkyrim = Game.find_by(display_name: "Skyrim")

  modSkyrim = Mod.create!(
      name: "Skyrim",
      authors: "Bethesda",
      submitted_by: submitter.id,
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
  skyrimOption = create_option(modSkyrim)
  create_plugin(skyrimOption, "Skyrim/Skyrim.esm.json")
  create_plugin(skyrimOption, "Skyrim/Update.esm.json")
  modSkyrim.update_lazy_counters

  modDawnguard = Mod.create!(
      name: "Dawnguard",
      authors: "Bethesda",
      submitted_by: submitter.id,
      is_official: true,
      game_id: gameSkyrim.id,
      primary_category_id: Category.find_by(name: "Locations").id,
      secondary_category_id: Category.find_by(name: "Gameplay - Factions").id,
      released: DateTime.new(2012, 8, 2),
      custom_sources_attributes: [{
          label: "Steam Store",
          url: "http://store.steampowered.com/app/211720/"
      }]
  )
  create_tags(submitter, modDawnguard, ["Vampires", "Dawnguard", "Werewolves", "Soul Cairn", "Dragonbone"])
  # Create plugins
  dawnguardOption = create_option(modDawnguard)
  create_plugin(dawnguardOption, "Skyrim/Dawnguard.esm.json")
  modDawnguard.update_lazy_counters

  modHearthfire = Mod.create!(
      name: "Hearthfire",
      authors: "Bethesda",
      submitted_by: submitter.id,
      is_official: true,
      game_id: gameSkyrim.id,
      primary_category_id: Category.find_by(name: "Locations - New Player Homes").id,
      secondary_category_id: Category.find_by(name: "Gameplay - Immersion & Role-playing").id,
      released: DateTime.new(2012, 10, 4),
      custom_sources_attributes: [{
          label: "Steam Store",
          url: "http://store.steampowered.com/app/220760/"
      }]
  )
  create_tags(submitter, modHearthfire, ["Building", "Family", "Marriage", "Adoption"])
  # Create plugins
  hearthfireOption = create_option(modHearthfire)
  create_plugin(hearthfireOption, "Skyrim/HearthFires.esm.json")
  modHearthfire.update_lazy_counters

  modDragonborn = Mod.create!(
      name: "Dragonborn",
      authors: "Bethesda",
      submitted_by: submitter.id,
      is_official: true,
      game_id: gameSkyrim.id,
      primary_category_id: Category.find_by(name: "Locations - New Lands").id,
      released: DateTime.new(2013, 2, 5),
      custom_sources_attributes: [{
          label: "Steam Store",
          url: "http://store.steampowered.com/app/211720/"
      }]
  )
  create_tags(submitter, modDragonborn, ["Solstheim", "Apocrypha", "Hermaeus Mora", "Shouts", "Stahlrim", "Nordic", "Bonemold", "Chitin"])
  # Create plugins
  dragonbornOption = create_option(modDragonborn)
  create_plugin(dragonbornOption, "Skyrim/Dragonborn.esm.json")
  modDragonborn.update_lazy_counters

  modHighRes = Mod.create!(
      name: "High Resolution Texture Pack",
      authors: "Bethesda",
      submitted_by: submitter.id,
      is_official: true,
      game_id: gameSkyrim.id,
      primary_category_id: Category.find_by(name: "Audiovisual - Models & Textures").id,
      released: DateTime.new(2012, 2, 7),
      custom_sources_attributes: [{
          label: "Steam Store",
          url: "http://store.steampowered.com/app/202485/"
      }]
  )
  create_tags(submitter, modHighRes, ["1K", "Armor", "Weapons", "Architecture", "Actors", "Dungeons", "Terrain", "Clutter"])
  # Create plugins
  highResOption = create_option(modHighRes)
  create_plugin(highResOption, "Skyrim/HighResTexturePack01.esp.json")
  create_plugin(highResOption, "Skyrim/HighResTexturePack02.esp.json")
  create_plugin(highResOption, "Skyrim/HighResTexturePack03.esp.json")
  modHighRes.update_lazy_counters
end

def seed_skyrimse_official_content(submitter)
  gameSkyrimSE = Game.find_by(display_name: "Skyrim SE")

  modSkyrimSE = Mod.create!(
      name: "Skyrim: Special Edition",
      authors: "Bethesda",
      submitted_by: submitter.id,
      is_official: true,
      game_id: gameSkyrimSE.id,
      released: DateTime.new(2016, 10, 28),
      updated: DateTime.new(2017, 1, 9),
      custom_sources_attributes: [{
          label: "Steam Store",
          url: "http://store.steampowered.com/app/489830/"
      }]
  )
  # Create config files
  create_config_file(modSkyrimSE, "Skyrim.ini", "{{MyGamesFolder}}")
  create_config_file(modSkyrimSE, "SkyrimPrefs.ini", "{{MyGamesFolder}}")
  # Create plugins
  skyrimSEOption = create_option(modSkyrimSE)
  create_plugin(skyrimSEOption, "SkyrimSE/Skyrim.esm.json")
  create_plugin(skyrimSEOption, "SkyrimSE/Update.esm.json")
  create_plugin(skyrimSEOption, "SkyrimSE/Dawnguard.esm.json")
  create_plugin(skyrimSEOption, "SkyrimSE/Hearthfires.esm.json")
  create_plugin(skyrimSEOption, "SkyrimSE/Dragonborn.esm.json")
  modSkyrimSE.update_lazy_counters
end

def seed_official_content
  puts "\nSeeding official content"

  # get helper variables
  mator = User.find_by(username: "Mator")

  # seed content
  seed_skyrim_official_content(mator)
  seed_skyrimse_official_content(mator)

  puts "    #{Mod.count} official mods seeded"
  puts "    #{Plugin.count} official plugins seeded"
end
