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

def seed_fake_users
  require 'securerandom'

  puts "\nSeeding users"
  # create an admin user
  pw = SecureRandom.urlsafe_base64
  User.create!(
      username: "admin",
      role: "admin",
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
  def time_rand(from = Time.new(2000), to = Time.now)
    Time.at(from + rand * (to.to_f - from.to_f)).to_date
  end

  # create 99 random users
  99.times do |n|
    # only allow up to the first 18 characters of a username from the
    # faker generated username
    name = Faker::Internet.user_name[0..17]
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

def seed_fake_mods
  puts "\nSeeding mods and nexus infos"

  # Helper vars
  nexusDateFormat = "%d/%m/%Y - %I:%M%p"
  gameSkyrim = Game.where({display_name: "Skyrim"}).first
  adminUser = User.find_by(:username => 'admin')

  # Top recently endorsed mods
  Mod.create(
      name: "SkyUI",
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

  Plugin.create({
    filename: "SkyUI.esp",
    mod_id: Mod.last.id,
    crc_hash: "BEA2DC76",
    file_size: 2385,
    description: "SkyUI 5.1\r\n",
    author: "SkyUI Team",
    override_count: 0,
    record_count: 8,
    masters_attributes: [],
    dummy_masters_attributes: [],
    plugin_errors_attributes: [],
    overrides_attributes: [],
    plugin_record_groups_attributes: [{
      sig: "QUST",
      override_count: 0,
      record_count: 7
    }]
  })

  Mod.create(
      name: "Immersive Armors",
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

  Mod.create(
      name: "Skyrim HD - 2K Textures",
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

  Mod.create(
      name: "RaceMenu",
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

  Mod.create(
      name: "Unofficial Skyrim Legendary Edition Patch",
      primary_category_id: Category.where(name: "Fixes").first.id,
      is_utility: false,
      has_adult_content: false,
      game_id: gameSkyrim.id,
      submitted_by: adminUser.id,
      released: DateTime.strptime("07/11/2015 - 08:41PM", nexusDateFormat)
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

  Mod.create(
      name: "Mod Organizer",
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

  Mod.create(
      name: "Skyrim Flora Overhaul",
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

  Mod.create(
      name: "TES5Edit",
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

# Top mods in the last 59 days
  Mod.create(
      name: "Merge Plugins",
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

  Mod.create(
      name: "The Lily - Armour Mashup",
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

  Mod.create(
      name: "THE PEOPLE OF SKYRIM ULTIMATE EDITION",
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

  Mod.create(
      name: "Skaal You Need - Skaal house and follower",
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

  Mod.create(
      name: "SC - Hairstyles",
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

  Mod.create(
      name: "Real Names",
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
end

def seed_fake_reviews
  # generate reviews on mods
  puts "\nSeeding reviews"
  Mod.all.each do |mod|
    nReviews = rand(6)
    puts "    Generating #{nReviews} reviews for #{mod.name}"
    nReviews.times do
      submitter = random_user
      review = mod.reviews.new(
          submitted_by: submitter.id,
          mod_id: mod.id,
          hidden: false,
          submitted: DateTime.now,
          text_body: Faker::Lorem.paragraph(15)
      )
      review.save!

      # seed ratings on reviews
      nRatings = rand(2..5)
      nRatings.times do
        section = random_review_section
        review.review_ratings.create(rating: rand(100), review_section_id: section.id)
      end

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
  nNotes = Mod.count
  nNotes.times do
    submitter = random_user
    cnote = CompatibilityNote.new(
        submitted_by: submitter.id,
        compatibility_type: CompatibilityNote.compatibility_types.keys.sample,
        submitted: Faker::Date.backward(14),
        text_body: Faker::Lorem.paragraph(4),
        first_mod_id: random_mod.id,
        second_mod_id: random_mod.id
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
  nNotes = Mod.count
  nNotes.times do
    submitter = random_user
    puts "    Generating install order note"
    ionote = InstallOrderNote.new(
        submitted_by: submitter.id,
        first_mod_id: random_mod.id,
        second_mod_id: random_mod.id,
        submitted: Faker::Date.backward(14),
        text_body: Faker::Lorem.paragraph(4)
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
  nNotes = Plugin.count
  nNotes.times do
    submitter = random_user
    puts "    Generating load order"
    lnote = LoadOrderNote.new(
        submitted_by: submitter.id,
        first_plugin_id: random_plugin.id,
        second_plugin_id: random_plugin.id,
        submitted: Faker::Date.backward(14),
        text_body: Faker::Lorem.paragraph(4)
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
    ModList.new(
        name: Faker::Lorem.words(3).join(' '),
        created_by: author.id,
        is_collection: [true, false].sample,
        hidden: [true, false].sample,
        has_adult_content: [true, false].sample,
        status: ModList.statuses.keys.sample,
        description: Faker::Lorem.paragraph(5),
        created: Faker::Date.backward(14),
        game_id: gameSkyrim.id
    ).save!
  end

  puts "    #{ModList.count} mod lists seeded"
end
