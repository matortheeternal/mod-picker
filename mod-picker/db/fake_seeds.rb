def randpow(num, pow)
  result = 1.0
  (1..pow).each do
    result *= rand(10000)/10000.0
  end
  (num * result).floor
end

def random_user
  User.offset(rand(User.count)).first
end

def random_review_section
  ReviewSection.offset(rand(ReviewSection.count)).first
end

def random_mod
  Mod.offset(rand(Mod.count)).first
end

def random_plugin
  Plugin.offset(rand(Plugin.count)).first
end

def random_game
  Game.offset(rand(Game.count)).first
end

def random_comment
  Comment.offset(rand(Comment.count)).first
end

def get_unique_mod_pair(model)
  mod_ids = [0, 0]
  while 1
    mod_ids[0] = random_mod.id
    mod_ids[1] = random_mod.id
    if mod_ids[0] != mod_ids[1] && model.where(first_mod_id: mod_ids, second_mod_id: mod_ids).empty?
      break
    end
  end
  mod_ids
end

def get_unique_plugin_pair(model)
  plugin_filenames = ["", ""]
  while 1
    plugin_filenames[0] = random_plugin.filename
    plugin_filenames[1] = random_plugin.filename
    if plugin_filenames[0] != plugin_filenames[1] && model.where(first_plugin_filename: plugin_filenames, second_plugin_filename: plugin_filenames).empty?
      break
    end
  end
  plugin_filenames
end

def get_unique_username
  name = Faker::Internet.user_name(4..20)
  username = name
  count = 1
  while User.find_by(username: username).present?
    username = name + count.to_s
    count += 1
  end
  username
end

def randomize_user_reputation_offsets
  rep_levels = [5, 20, 40, 80, 160, 320, 640, 1280]
  UserReputation.all.each do |rep|
    rep.offset = rep_levels.sample * rand(1.0..2.0)
    rep.calculate_overall_rep
    rep.save
  end
end

def random_rep
  UserReputation.offset(rand(UserReputation.count)).first
end

def create_random_rep_links
  UserReputation.all.each do |rep|
    next if rep.overall < 40
    num_links = rand(rep.get_max_links)
    invalid_ids = [rep.id]
    num_links.times do
      begin
        target_rep = random_rep
      end while invalid_ids.include?(target_rep.id)
      ReputationLink.create(from_rep_id: rep.id, to_rep_id: target_rep.id)
      invalid_ids.push(target_rep.id)
    end
  end
end

def seed_fake_users(num_users)
  require 'securerandom'

  puts "\nSeeding users"

  # generates random date between year 2000 and now.
  def time_rand(from = Time.new(2000), to = Time.now)
    Time.at(from + rand * (to.to_f - from.to_f)).to_date
  end

  # create random users
  num_users.times do |n|
    username = get_unique_username
    pw = SecureRandom.urlsafe_base64
    User.create!(
        username: username,
        joined: time_rand,
        email: Faker::Internet.email(username),
        password: pw,
        password_confirmation: pw,
        confirmed_at: Time.now.to_date,
    )
  end
  puts "    #{User.count} users seeded"
end

def seed_fake_mods
  puts "\nSeeding mods and nexus infos"

  # Helper vars
  nexusDateFormat = "%d/%m/%Y - %I:%M%p"
  gameSkyrim = Game.where({display_name: "Skyrim"}).first
  adminUser = User.find_by(:role => "admin")

  # Top recently endorsed mods
  Mod.create(
      name: "SkyUI",
      authors: "SkyUI Team",
      primary_category_id: Category.where(name: "Gameplay - User Interface").first.id,
      secondary_category_id: Category.where(name: "Resources - Frameworks").first.id,
      is_utility: false,
      has_adult_content: false,
      game_id: gameSkyrim.id,
      submitted_by: adminUser.id,
      released: DateTime.strptime("17/12/2011 - 12:24AM", nexusDateFormat)
  )

  NexusInfo.create(
      id: 3863,
      mod_id: Mod.last.id,
      mod_name: Mod.last.name,
      game_id: gameSkyrim.id,
      uploaded_by: "schlangster",
      authors: "SkyUI Team",
      released: DateTime.strptime("17/12/2011 - 12:24AM", nexusDateFormat),
      updated: DateTime.strptime("24/08/2015 - 03:38PM", nexusDateFormat),
      endorsements: 404927,
      downloads: 11244061,
      unique_downloads: 5703525,
      views: 26258557,
      posts_count: 17040,
      videos_count: 23,
      images_count: 23,
      files_count: 14,
      articles_count: 1,
      nexus_category: 42
  )

  Plugin.create({
    filename: "SkyUI.esp",
    game_id: gameSkyrim.id,
    mod_id: Mod.last.id,
    crc_hash: "BEA2DC76",
    file_size: 2385,
    description: "SkyUI 5.1\r\n",
    author: "SkyUI Team",
    override_count: 0,
    record_count: 8,
    plugin_record_groups_attributes: [{
      sig: "QUST",
      override_count: 0,
      record_count: 7
    }]
  })

  Mod.last.update_lazy_counters

  Mod.create(
      name: "Immersive Armors",
      authors: "Hothtrooper44",
      primary_category_id: Category.where(name: "Items - Armor, Clothing, & Accessories").first.id,
      is_utility: false,
      has_adult_content: false,
      game_id: gameSkyrim.id,
      submitted_by: adminUser.id,
      released: DateTime.strptime("01/07/2012 - 07:23PM", nexusDateFormat)
  )

  NexusInfo.create(
      id: 19733,
      mod_id: Mod.last.id,
      mod_name: Mod.last.name,
      game_id: gameSkyrim.id,
      uploaded_by: "hothtrooper44",
      authors: "Hothtrooper44",
      released: DateTime.strptime("01/07/2012 - 07:23PM", nexusDateFormat),
      updated: DateTime.strptime("20/01/2016 - 12:16AM", nexusDateFormat),
      endorsements: 208078,
      downloads: 6423440,
      unique_downloads: 2936645,
      views: 16208593,
      posts_count: 15646,
      videos_count: 16,
      images_count: 454,
      files_count: 25,
      articles_count: 3,
      nexus_category: 54
  )

  Mod.create(
      name: "Skyrim HD - 2K Textures",
      authors: "NebuLa from AHBmods",
      primary_category_id: Category.where(name: "Audiovisual - Models & Textures").first.id,
      is_utility: false,
      has_adult_content: false,
      game_id: gameSkyrim.id,
      submitted_by: adminUser.id,
      released: DateTime.strptime("19/11/2011 - 01:03AM", nexusDateFormat)
  )

  NexusInfo.create(
      id: 607,
      mod_id: Mod.last.id,
      mod_name: Mod.last.name,
      game_id: gameSkyrim.id,
      uploaded_by: "NebuLa1",
      authors: "NebuLa from AHBmods",
      released: DateTime.strptime("19/11/2011 - 01:03AM", nexusDateFormat),
      updated: DateTime.strptime("09/01/2016 - 04:57PM", nexusDateFormat),
      endorsements: 158069,
      downloads: 17720870,
      unique_downloads: 8524444,
      views: 20530426,
      posts_count: 8494,
      videos_count: 26,
      images_count: 161,
      files_count: 23,
      articles_count: 0,
      nexus_category: 29
  )

  Mod.create(
      name: "RaceMenu",
      authors: "Expired",
      primary_category_id: Category.where(name: "Gameplay - User Interface").first.id,
      secondary_category_id: Category.where(name: "Resources - Frameworks").first.id,
      is_utility: false,
      has_adult_content: false,
      game_id: gameSkyrim.id,
      submitted_by: adminUser.id,
      released: DateTime.strptime("08/01/2013 - 01:10AM", nexusDateFormat)
  )

  NexusInfo.create(
      id: 29624,
      mod_id: Mod.last.id,
      mod_name: Mod.last.name,
      game_id: gameSkyrim.id,
      uploaded_by: "expired6978",
      authors: "Expired",
      released: DateTime.strptime("08/01/2013 - 01:10AM", nexusDateFormat),
      updated: DateTime.strptime("18/01/2016 - 10:37AM", nexusDateFormat),
      endorsements: 148874,
      downloads: 4187681,
      unique_downloads: 2890642,
      views: 9661000,
      posts_count: 10047,
      videos_count: 8,
      images_count: 258,
      files_count: 104,
      articles_count: 0,
      nexus_category: 42
  )

  Mod.create(
      name: "Unofficial Skyrim Legendary Edition Patch",
      authors: "Unofficial Patch Project Team ",
      primary_category_id: Category.where(name: "Fixes").first.id,
      is_utility: false,
      has_adult_content: false,
      game_id: gameSkyrim.id,
      submitted_by: adminUser.id,
      released: DateTime.strptime("07/11/2015 - 08:41PM", nexusDateFormat),
      required_mods_attributes: [{
          required_id: Mod.find_by(name: "Dawnguard").id
      }, {
          required_id: Mod.find_by(name: "Hearthfire").id
      }, {
          required_id: Mod.find_by(name: "Dragonborn").id
      }]
  )

  NexusInfo.create(
      id: 71214,
      mod_id: Mod.last.id,
      mod_name: Mod.last.name,
      game_id: gameSkyrim.id,
      uploaded_by: "Arthmoor",
      authors: "Unofficial Patch Project Team ",
      released: DateTime.strptime("07/11/2015 - 08:41PM", nexusDateFormat),
      updated: DateTime.strptime("20/01/2016 - 06:41PM", nexusDateFormat),
      endorsements: 14628,
      downloads: 272979,
      unique_downloads: 183781,
      views: 742126,
      posts_count: 1703,
      videos_count: 1,
      images_count: 15,
      files_count: 1,
      articles_count: 0,
      nexus_category: 84
  )

  Mod.create(
      name: "Mod Organizer",
      authors: "Tannin",
      primary_category_id: Category.where(name: "Utilities - Tools").first.id,
      is_utility: true,
      has_adult_content: false,
      game_id: gameSkyrim.id,
      submitted_by: adminUser.id,
      released: DateTime.strptime("24/11/2011 - 03:30PM", nexusDateFormat)
  )

  NexusInfo.create(
      id: 1334,
      mod_id: Mod.last.id,
      mod_name: Mod.last.name,
      game_id: gameSkyrim.id,
      uploaded_by: "Tannin42",
      authors: "Tannin",
      released: DateTime.strptime("24/11/2011 - 03:30PM", nexusDateFormat),
      updated: DateTime.strptime("01/12/2015 - 09:23PM", nexusDateFormat),
      endorsements: 88697,
      downloads: 2078942,
      unique_downloads: 1507428,
      views: 4833168,
      posts_count: 13016,
      videos_count: 35,
      images_count: 4,
      files_count: 27,
      articles_count: 0,
      nexus_category: 39
  )

  Mod.create(
      name: "Skyrim Flora Overhaul",
      authors: "vurt",
      primary_category_id: Category.where(name: "Audiovisual - Models & Textures").first.id,
      is_utility: false,
      has_adult_content: false,
      game_id: gameSkyrim.id,
      submitted_by: adminUser.id,
      released: DateTime.strptime("13/11/2011 - 10:36PM", nexusDateFormat)
  )

  NexusInfo.create(
      id: 141,
      mod_id: Mod.last.id,
      mod_name: Mod.last.name,
      game_id: gameSkyrim.id,
      uploaded_by: "vurt",
      authors: "vurt",
      released: DateTime.strptime("13/11/2011 - 10:36PM", nexusDateFormat),
      updated: DateTime.strptime("16/01/2016 - 10:15PM", nexusDateFormat),
      endorsements: 99308,
      downloads: 5225456,
      unique_downloads: 3342510,
      views: 10248390,
      posts_count: 10586,
      videos_count: 47,
      images_count: 741,
      files_count: 35,
      articles_count: 0,
      nexus_category: 29
  )

  Mod.create(
      name: "TES5Edit",
      authors: "ElminsterAU",
      primary_category_id: Category.where(name: "Utilities - Tools").first.id,
      secondary_category_id: Category.where(name: "Resources - Frameworks").first.id,
      is_utility: true,
      has_adult_content: false,
      game_id: gameSkyrim.id,
      submitted_by: adminUser.id,
      released: DateTime.strptime("22/10/2012 - 06:22AM", nexusDateFormat)
  )

  NexusInfo.create(
      id: 25859,
      mod_id: Mod.last.id,
      mod_name: Mod.last.name,
      game_id: gameSkyrim.id,
      uploaded_by: "Sharlikran",
      authors: "ElminsterAU",
      released: DateTime.strptime("22/10/2012 - 06:22AM", nexusDateFormat),
      updated: DateTime.strptime("10/11/2015 - 07:43AM", nexusDateFormat),
      endorsements: 80385,
      downloads: 1597970,
      unique_downloads: 1162331,
      views: 4606415,
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
      authors: "Mator",
      primary_category_id: Category.where(name: "Utilities - Tools").first.id,
      is_utility: true,
      has_adult_content: false,
      game_id: gameSkyrim.id,
      submitted_by: adminUser.id,
      released: DateTime.strptime("24/12/2015 - 01:56AM", nexusDateFormat)
  )

  NexusInfo.create(
      id: 69905,
      mod_id: Mod.last.id,
      mod_name: Mod.last.name,
      game_id: gameSkyrim.id,
      uploaded_by: "matortheeternal",
      authors: "Mator",
      released: DateTime.strptime("24/12/2015 - 01:56AM", nexusDateFormat),
      updated: DateTime.strptime("05/01/2016 - 09:16AM", nexusDateFormat),
      endorsements: 1099,
      downloads: 12487,
      unique_downloads: 11147,
      views: 92672,
      posts_count: 701,
      videos_count: 0,
      images_count: 15,
      files_count: 3,
      articles_count: 0,
      nexus_category: 39
  )

  Mod.create(
      name: "The Lily - Armour Mashup",
      authors: "pottoply",
      primary_category_id: Category.where(name: "Items - Armor, Clothing, & Accessories").first.id,
      is_utility: false,
      has_adult_content: false,
      game_id: gameSkyrim.id,
      submitted_by: adminUser.id,
      released: DateTime.strptime("08/12/2015 - 09:42PM", nexusDateFormat)
  )

  NexusInfo.create(
      id: 71843,
      mod_id: Mod.last.id,
      mod_name: Mod.last.name,
      game_id: gameSkyrim.id,
      uploaded_by: "pottoply",
      authors: "pottoply",
      released: DateTime.strptime("08/12/2015 - 09:42PM", nexusDateFormat),
      updated: DateTime.strptime("19/01/2016 - 07:58PM", nexusDateFormat),
      endorsements: 921,
      downloads: 23264,
      unique_downloads: 19418,
      views: 122787,
      posts_count: 207,
      videos_count: 6,
      images_count: 46,
      files_count: 15,
      articles_count: 0,
      nexus_category: 54
  )

  Mod.create(
      name: "THE PEOPLE OF SKYRIM ULTIMATE EDITION",
      authors: "Nesbit",
      primary_category_id: Category.where(name: "Gameplay - Immersion & Role-playing").first.id,
      secondary_category_id: Category.where(name: "New Characters").first.id,
      is_utility: false,
      has_adult_content: false,
      game_id: gameSkyrim.id,
      submitted_by: adminUser.id,
      released: DateTime.strptime("05/01/2016 - 10:31AM", nexusDateFormat)
  )

  NexusInfo.create(
      id: 72449,
      mod_id: Mod.last.id,
      mod_name: Mod.last.name,
      game_id: gameSkyrim.id,
      uploaded_by: "nesbit098",
      authors: "Nesbit",
      released: DateTime.strptime("05/01/2016 - 10:31AM", nexusDateFormat),
      updated: DateTime.strptime("24/01/2016 - 02:41AM", nexusDateFormat),
      endorsements: 970,
      downloads: 57197,
      unique_downloads: 37661,
      views: 196131,
      posts_count: 1397,
      videos_count: 0,
      images_count: 26,
      files_count: 29,
      articles_count: 3,
      nexus_category: 78
  )

  Mod.create(
      name: "Skaal You Need - Skaal house and follower",
      authors: "Elianora",
      primary_category_id: Category.where(name: "Locations - New Player Homes").first.id,
      secondary_category_id: Category.where(name: "New Characters - Allies").first.id,
      is_utility: false,
      has_adult_content: false,
      game_id: gameSkyrim.id,
      submitted_by: adminUser.id,
      released: DateTime.strptime("17/12/2015 - 09:23PM", nexusDateFormat)
  )

  NexusInfo.create(
      id: 72005,
      mod_id: Mod.last.id,
      mod_name: Mod.last.name,
      game_id: gameSkyrim.id,
      uploaded_by: "Elianora",
      authors: "Elianora",
      released: DateTime.strptime("17/12/2015 - 09:23PM", nexusDateFormat),
      updated: DateTime.strptime("20/01/2016 - 07:36PM", nexusDateFormat),
      endorsements: 737,
      downloads: 12276,
      unique_downloads: 9996,
      views: 96800,
      posts_count: 242,
      videos_count: 2,
      images_count: 35,
      files_count: 4,
      articles_count: 0,
      nexus_category: 67
  )

  Mod.create(
      name: "SC - Hairstyles",
      authors: "ShinglesCat",
      primary_category_id: Category.where(name: "Character Appearance - Face Parts").first.id,
      is_utility: false,
      has_adult_content: false,
      game_id: gameSkyrim.id,
      submitted_by: adminUser.id,
      released: DateTime.strptime("25/11/2015 - 09:21AM", nexusDateFormat)
  )

  NexusInfo.create(
      id: 71561,
      mod_id: Mod.last.id,
      mod_name: Mod.last.name,
      game_id: gameSkyrim.id,
      uploaded_by: "ShinglesCat",
      authors: "ShinglesCat",
      released: DateTime.strptime("25/11/2015 - 09:21AM", nexusDateFormat),
      updated: DateTime.strptime("02/01/2016 - 06:11PM", nexusDateFormat),
      endorsements: 650,
      downloads: 10243,
      unique_downloads: 8640,
      views: 90865,
      posts_count: 98,
      videos_count: 3,
      images_count: 61,
      files_count: 2,
      articles_count: 0,
      nexus_category: 26
  )

  Mod.create(
      name: "Real Names",
      authors: "Jaxonz and Nellshini",
      primary_category_id: Category.where(name: "Gameplay - Immersion & Role-playing").first.id,
      is_utility: false,
      has_adult_content: false,
      game_id: gameSkyrim.id,
      submitted_by: adminUser.id,
      released: DateTime.strptime("23/11/2015 - 02:11AM", nexusDateFormat)
  )

  NexusInfo.create(
      id: 71464,
      mod_id: Mod.last.id,
      mod_name: Mod.last.name,
      game_id: gameSkyrim.id,
      uploaded_by: "nellshini",
      authors: "Jaxonz and Nellshini",
      released: DateTime.strptime("23/11/2015 - 02:11AM", nexusDateFormat),
      updated: DateTime.strptime("21/01/2016 - 07:01AM", nexusDateFormat),
      endorsements: 665,
      downloads: 11142,
      unique_downloads: 9654,
      views: 47429,
      posts_count: 166,
      videos_count: 0,
      images_count: 6,
      files_count: 4,
      articles_count: 0,
      nexus_category: 78
  )

  puts "    #{Mod.count} mods seeded"
  puts "    #{NexusInfo.count} nexus infos seeded"
  puts "    #{Plugin.count} plugins seeded"
end

def seed_fake_tags
  # helper variables
  gameSkyrim = Game.where({display_name: "Skyrim"}).first

  # generate tags
  puts "\nSeeding tags"

  Tag.create(
      text: "Dwemer",
      game_id: gameSkyrim.id,
      submitted_by: random_user.id
  )
  Tag.create(
      text: "Has MCM",
      game_id: gameSkyrim.id,
      submitted_by: random_user.id
  )
  Tag.create(
      text: "Requires SKSE",
      game_id: gameSkyrim.id,
      submitted_by: random_user.id
  )
  Tag.create(
      text: "Mod Management",
      game_id: gameSkyrim.id,
      submitted_by: random_user.id
  )
  Tag.create(
      text: "Has FOMOD",
      game_id: gameSkyrim.id,
      submitted_by: random_user.id
  )
  Tag.create(
      text: "Not Lore Friendly",
      game_id: gameSkyrim.id,
      submitted_by: random_user.id
  )
  Tag.create(
      text: "Skimpy",
      game_id: gameSkyrim.id,
      submitted_by: random_user.id
  )
  Tag.create(
      text: "Plants",
      game_id: gameSkyrim.id,
      submitted_by: random_user.id
  )
  Tag.create(
      text: "AI",
      game_id: gameSkyrim.id,
      submitted_by: random_user.id
  )
  Tag.create(
      text: "Racemenu Overlay",
      game_id: gameSkyrim.id,
      submitted_by: random_user.id
  )
  Tag.create(
      text: "UI",
      game_id: gameSkyrim.id,
      submitted_by: random_user.id
  )
  Tag.create(
      text: "New Mechanics",
      game_id: gameSkyrim.id,
      submitted_by: random_user.id
  )
  Tag.create(
      text: "Sexy",
      game_id: gameSkyrim.id,
      submitted_by: random_user.id
  )
  Tag.create(
      text: "Dragons",
      game_id: gameSkyrim.id,
      submitted_by: random_user.id
  )
  Tag.create(
      text: "Shiny",
      game_id: gameSkyrim.id,
      submitted_by: random_user.id
  )

  puts "    Applying tags to mods"
  Mod.all.each do |mod|
    rnd = randpow(10, 2)
    puts "      Applying #{rnd} tags to #{mod.name}"
    rnd.times do
      submitter = random_user
      mod.mod_tags.new(
        submitted_by: submitter.id,
        tag_id: Tag.offset(rand(Tag.count)).first.id
      ).save!
    end
  end

  puts "    Applying tags to mod lists"
  ModList.all.each do |modlist|
    rnd = randpow(10, 2)
    puts "      Applying #{rnd} tags to #{modlist.name}"
    rnd.times do
      submitter = random_user
      modlist.mod_list_tags.new(
          submitted_by: submitter.id,
          tag_id: Tag.offset(rand(Tag.count)).first.id
      ).save!
    end
  end
end

def seed_fake_comments
  # generate comments on user profiles
  puts "\nSeeding user comments"
  User.all.each do |user|
    rnd = randpow(10, 2)
    puts "    Generating #{rnd} comments for #{user.username}"
    rnd.times do
      submitter = random_user
      user.profile_comments.new(
          submitted_by: submitter.id,
          hidden: false,
          submitted: Faker::Date.backward(14),
          text_body: Faker::Lorem.paragraph(1)
      ).save!
    end
  end
  puts "\nSeeding article comments"
  Article.all.each do |article|
    rnd = randpow(10, 2)
    puts "    Generating #{rnd} comments for #{article.title}"
    rnd.times do
      submitter = random_user
      article.comments.new(
          submitted_by: submitter.id,
          hidden: false,
          submitted: Faker::Date.backward(14),
          text_body: Faker::Lorem.paragraph(1)
      ).save!
    end
  end
end

def seed_fake_reviews
  puts "\nSeeding reviews"

  # helper variables
  gameSkyrim = Game.where({display_name: "Skyrim"}).first

  # generate reviews on mods
  Mod.all.each do |mod|
    if mod.primary_category_id.nil?
      next
    end

    nReviews = rand(6)
    puts "    Generating #{nReviews} reviews for #{mod.name}"
    nReviews.times do
      submitter = random_user

      review_ratings = []
      category_ids = [mod.primary_category_id]
      category_ids.push(mod.primary_category.parent_id) if mod.primary_category.parent_id
      review_sections = ReviewSection.where(category_id: category_ids)
      max_review_ratings = rand(2..5)
      review_sections.each do |section|
        break if review_ratings.length == max_review_ratings
        review_ratings.push({review_section_id: section.id, rating: rand(100)})
      end

      next if Review.exists?(submitted_by: submitter.id)

      review = mod.reviews.new(
          game_id: gameSkyrim.id,
          submitted_by: submitter.id,
          mod_id: mod.id,
          hidden: false,
          submitted: DateTime.now,
          text_body: Faker::Lorem.paragraph(18),
          review_ratings_attributes: review_ratings
      )
      review.save!

      # seed helpful marks on reviews
      nHelpfulMarks = randpow(10, 3)
      nHelpfulMarks.times do
        submitter = random_user
        review.helpful_marks.new(
            submitted_by: submitter.id,
            helpful: rand > 0.35
        ).save!
      end
    end
  end

  puts "    #{Review.count} review seeded"
end

def seed_fake_compatibility_notes
  puts "\nSeeding compatibility notes"

  # helper variables
  gameSkyrim = Game.where({display_name: "Skyrim"}).first

  nNotes = Mod.count
  nNotes.times do
    submitter = random_user
    (first_mod_id, second_mod_id) = get_unique_mod_pair(CompatibilityNote)
    cnote = CompatibilityNote.new(
        game_id: gameSkyrim.id,
        submitted_by: submitter.id,
        status: CompatibilityNote.statuses.keys.sample,
        submitted: Faker::Date.backward(14),
        text_body: Faker::Lorem.paragraph(10),
        first_mod_id: first_mod_id,
        second_mod_id: second_mod_id
    )
    cnote.save!

    # seed helpful marks on cnotes
    nHelpfulMarks = randpow(10, 3)
    nHelpfulMarks.times do
      submitter = random_user
      cnote.helpful_marks.new(
          submitted_by: submitter.id,
          helpful: rand > 0.35
      ).save!
    end
  end

  puts "    #{CompatibilityNote.count} compatibility notes seeded"
end

def seed_fake_install_order_notes
  puts "\nSeeding install order notes"

  # helper variables
  gameSkyrim = Game.where({display_name: "Skyrim"}).first
  nNotes = Mod.count
  nNotes.times do
    submitter = random_user
    (first_mod_id, second_mod_id) = get_unique_mod_pair(InstallOrderNote)
    ionote = InstallOrderNote.new(
        game_id: gameSkyrim.id,
        submitted_by: submitter.id,
        first_mod_id: first_mod_id,
        second_mod_id: second_mod_id,
        submitted: Faker::Date.backward(14),
        text_body: Faker::Lorem.paragraph(10)
    )
    ionote.save!

    # seed helpful marks on ionotes
    nHelpfulMarks = randpow(10, 3)
    nHelpfulMarks.times do
      submitter = random_user
      ionote.helpful_marks.new(
          submitted_by: submitter.id,
          helpful: rand > 0.35
      ).save!
    end
  end

  puts "    #{InstallOrderNote.count} install order notes seeded"
end

def seed_fake_load_order_notes
  puts "\nSeeding load order notes"

  # helper variables
  gameSkyrim = Game.where({display_name: "Skyrim"}).first

  nNotes = Plugin.count
  nNotes.times do
    submitter = random_user
    (first_plugin_filename, second_plugin_filename) = get_unique_plugin_pair(LoadOrderNote)
    lnote = LoadOrderNote.new(
        game_id: gameSkyrim.id,
        submitted_by: submitter.id,
        first_plugin_filename: first_plugin_filename,
        second_plugin_filename: second_plugin_filename,
        submitted: Faker::Date.backward(14),
        text_body: Faker::Lorem.paragraph(10)
    )
    lnote.save!

    # seed helpful marks on ionotes
    nHelpfulMarks = randpow(10, 3)
    nHelpfulMarks.times do
      submitter = random_user
      lnote.helpful_marks.new(
          submitted_by: submitter.id,
          helpful: rand > 0.35
      ).save!
    end
  end

  puts "    #{LoadOrderNote.count} load order notes seeded"
end

def seed_fake_mod_authors
  puts "\nSeeding mod authors"
  Mod.all.each do |mod|
    nModAuthors = 1 + randpow(2, 6)
    nModAuthors.times do
      author = User.offset(rand(User.count)).first
      ModAuthor.new(
          mod_id: mod.id,
          user_id: author.id
      ).save!
    end
  end

  puts "    #{ModAuthor.count} mod authors seeded"
end

def seed_fake_mod_lists
  puts "\nSeeding mod lists"

  # helper variables
  gameSkyrim = Game.where({display_name: "Skyrim"}).first

  # seed the mod lists
  nModLists = User.count / 2
  nModLists.times do
    author = User.offset(rand(User.count)).first
    mod_list = ModList.create!(
        name: Faker::Lorem.words(3).join(' '),
        submitted_by: author.id,
        is_collection: [true, false].sample,
        hidden: [true, false].sample,
        has_adult_content: [true, false].sample,
        status: ModList.statuses.keys.sample,
        description: Faker::Lorem.paragraph(5),
        submitted: Faker::Date.backward(14),
        game_id: gameSkyrim.id
    )
    plugin_index = 0
    Mod.all.each_with_index do |mod, index|
      mod_list.mod_list_mods.create!(
        mod_id: mod.id,
        index: index
      )
      mod.plugins.each do |plugin|
        mod_list.mod_list_plugins.create!(
          plugin_id: plugin.id,
          index: plugin_index
        )
        plugin_index += 1
      end
    end
  end

  puts "    #{ModList.count} mod lists seeded"
end

def seed_fake_help_pages
  puts "\nSeeding help pages"

  # TODO: Move this to a text file or something
  markdown_text = %Q{
    Markdown Cheatsheet
===================

- - - - 

# Heading 1 #

    Markup :  # Heading 1 #

## Heading 2 ##

    Markup :  ## Heading 2 ##

### Heading 3 ###

    Markup :  ### Heading 3 ###

#### Heading 4 ####

    Markup :  #### Heading 4 ####


Common text

    Markup :  Common text

_Emphasized text_

    Markup :  _Emphasized text_ or *Emphasized text*

~~Strikethrough text~~

    Markup :  ~~Strikethrough text~~

__Strong text__

    Markup :  __Strong text__ or **Strong text**

___Strong emphasized text___

    Markup :  ___Strong emphasized text___ or ***Strong emphasized text***

[Named Link](http://www.google.fr/) and http://www.google.fr/ or <http://example.com/>

    Markup :  [Named Link](http://www.google.fr/) and http://www.google.fr/ or <http://example.com/>

Table, like this one :

First Header  | Second Header
------------- | -------------
Content Cell  | Content Cell
Content Cell  | Content Cell

```
First Header  | Second Header
------------- | -------------
Content Cell  | Content Cell
Content Cell  | Content Cell
```

`code()`

    Markup :  `code()`

```javascript
    var specificLanguage_code = 
    {
        "data": {
            "lookedUpPlatform": 1,
            "query": "Kasabian+Test+Transmission",
            "lookedUpItem": {
                "name": "Test Transmission",
                "artist": "Kasabian",
                "album": "Kasabian",
                "picture": null,
                "link": "http://open.spotify.com/track/5jhJur5n4fasblLSCOcrTp"
            }
        }
    }
```

    Markup : ```javascript
             ```

* Bullet list
 * Nested bullet
  * Sub-nested bullet etc
* Bullet list item 2

~~~
 Markup : * Bullet list
           * Nested bullet
            * Sub-nested bullet etc
          * Bullet list item 2
~~~

1. A numbered list
 1. A nested numbered list
 2. Which is numbered
2. Which is numbered

~~~
 Markup : 1. A numbered list
           1. A nested numbered list
           2. Which is numbered
          2. Which is numbered
~~~

> Blockquote
>> Nested blockquote

    Markup :  > Blockquote
              >> Nested Blockquote

_Horizontal line :_
- - - -

    Markup :  - - - -

_Image with alt :_

![picture alt](http://www.brightlightpictures.com/assets/images/portfolio/thethaw_header.jpg "Title is optional")

    Markup : ![picture alt](http://www.brightlightpictures.com/assets/images/portfolio/thethaw_header.jpg "Title is optional")
}

  # seeding one page with markdown examples
  author = User.offset(rand(User.count)).first
  HelpPage.new(
    category: HelpPage.categories.keys.sample,
    game: random_game,
    submitted_by: author.id,
    title: Faker::Lorem.words(4).join(' '),
    text_body: markdown_text,
    submitted: Faker::Date.backward(10),
    edited: Faker::Date.backward(9)
  ).save!  

  30.times do
    author = User.offset(rand(User.count)).first
    HelpPage.new(
      category: HelpPage.categories.keys.sample,
      game: random_game,
      submitted_by: author.id,
      title: Faker::Lorem.words(4).join(' '),
      text_body: Faker::Lorem.words(rand(300) + 30).join(' '),
      submitted: Faker::Date.backward(10),
      edited: Faker::Date.backward(9)
    ).save!
  end

  puts "    #{HelpPage.count} help pages saved"
end

def seed_fake_articles
  puts "\nSeeding articles"

  gameSkyrim = Game.where({display_name: "Skyrim"}).first

  rand(50).times do
    author = User.offset(rand(User.count)).first
    Article.new(
        title: Faker::Lorem.words(3).join(' '),
        submitted_by: author.id,
        text_body: Faker::Lorem.words(rand(500)).join(' '),
        submitted: Faker::Date.backward(14),
        edited: Faker::Date.backward(13),
        game_id: gameSkyrim.id
    ).save!
  end

  puts "    #{Article.count} articles seeded"
end


# seeds fake corrections + agreement marks
# requires redis to be running to automatically expire corrections after 7 days
def seed_fake_corrections
    puts "\nSeeding fake corrections"

    # helper variables
    gameSkyrim = Game.where({display_name: "Skyrim"}).first
    nMods = Mod.count
    nMods.times do
        submitter = random_user
        mod = random_mod
        correction = Correction.new(
            game_id: gameSkyrim.id,
            submitted_by: submitter.id,
            correctable_id: mod.id,
            correctable_type: mod.class.name,
            title: Faker::Lorem.words(3).join(' '),
            text_body: Faker::Lorem.paragraph(10),
            status: Correction.statuses.keys.sample,
            mod_status: mod.status,
            submitted: Faker::Date.backward(14),
        )
        correction.save!

        # seed agreement marks on corrections
        # rand > 0.3 is weighted to 70% chance of being true
        nAgreementMarks = randpow(10, 3)
        nAgreementMarks.times do
            submitter = random_user
            correction.agreement_marks.new(
                correction_id: correction.id,
                submitted_by: submitter.id,
                agree: rand > 0.4,
        ).save!
        end
        puts "    #{AgreementMark.count} agreement marks seeded for correction #{correction.id}"
    end
    puts "    #{Correction.count} corrections seeded"
end

# seeds base_reports using random comments as the reportable type/id
# comments, reviews, tags, compatibility notes, install order notes, load order notes, mods, mod lists, corrections, and users

# should seed base_reports to all models that include Reportable 
# then seed a random number of reports for each base_report
def seed_fake_base_reports
  puts "\nSeeding base reports"

  reportable_list = [User, Comment, Review, Tag, CompatibilityNote, InstallOrderNote, LoadOrderNote, Mod, ModList, Correction]
  reportable_list.each do |reportable_model|
    if reportable_model.count > 1
        nReportables = [rand(1..reportable_model.count), 5].min
        reportable_model.first(nReportables).each do |reportable|
            base_report = BaseReport.new(
                reportable_id: reportable.id,
                reportable_type: reportable.class.name,
                submitted: Faker::Date.backward(14)
            )
            base_report.save!

            seed_fake_reports(base_report)
        end
    end
  end

  puts "    #{BaseReport.count} base_reports seeded"
  puts "    #{Report.count} total reports seeded"
end

# Helper method to be used with seed_fake_base_reports
# can be used by itself if passed a base_report record
def seed_fake_reports(base_report)
  puts "\nSeeding reports"

  rand(1..10).times do
    report = Report.new(
        base_report_id: base_report.id,
        submitted_by: random_user.id,
        reason: Report.reasons.keys.sample
    )
    report.note = Faker::Lorem.words(4).join(' ') if report.reason == :other
    report.save!
  end

  puts "    #{base_report.reports.count} reports seeded"
end
