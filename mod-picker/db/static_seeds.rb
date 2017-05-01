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

def create_tag_groups(game_name)
  filename = game_name.downcase.gsub(" ", "_") + ".json"
  file = File.read(Rails.root.join("db", "tag_groups", filename))
  game = Game.find_by(display_name: game_name)
  JSON.parse(file).each do |tag_group|
    tag_group["game_id"] = game.id
    category = Category.find_by(name: tag_group["category_name"])
    tag_group["category_id"] = category.id
    TagGroup.create!(tag_group.with_indifferent_access)
  end
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

def fix_terms(license, terms, keys)
  keys.each do |key|
    license[key] = terms[license[key]]
  end
end

def seed_licenses
  puts "\nSeeding licenses"
  terms = {
      "unknown" => -1,
      "no" => 0,
      "yes" => 1,
      "maybe" => 2
  }
  term_keys = ["credit", "commercial", "redistribution", "modification", "private_use", "include"]

  file = File.read(Rails.root.join("db", "licenses", "license.json"))
  JSON.parse(file).each do |license|
    fix_terms(license, terms, term_keys)
    License.create(license)
  end

  puts "    #{License.count} licenses seeded"
end

def seed_categories
  puts "\nSeeding categories"

  file = File.read(Rails.root.join("db", "categories", "categories.json"))
  json = JSON.parse(file).with_indifferent_access

  # super-categories
  json["categories"].each do |category|
    Category.create(category.except("subcategories"))
  end

  puts "    #{Category.count} categories seeded"

  # sub-categories
  json["categories"].each do |supercategory|
    category = Category.find_by(name: supercategory["name"])
    supercategory["subcategories"].each do |subcategory|
      subcategory["parent_id"] = category.id
      Category.create(subcategory)
    end
  end

  puts "    #{Category.where.not(parent_id: nil).count} sub-categories seeded"

  # build category name-id map
  category_map = {}
  Category.find_each do |category|
    category_map[category.name] = category.id
  end

  # category priorities
  json["category_priorities"].each do |priority|
    priority["dominant_id"] = category_map[priority["dominant_name"]]
    priority["recessive_id"] = category_map[priority["recessive_name"]]
    CategoryPriority.create(priority.except("dominant_name", "recessive_name"))
  end

  puts "    #{CategoryPriority.count} category priorities seeded"

  # review sections
  json["review_sections"].each do |review_section|
    review_section["category_id"] = category_map[review_section["category_name"]]
    ReviewSection.create(review_section.except("category_name"))
  end

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

def seed_tag_groups
  create_tag_groups("Skyrim")
  create_tag_groups("Skyrim SE")
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
