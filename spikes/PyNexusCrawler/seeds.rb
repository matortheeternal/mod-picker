Mod.create(
    name: "SkyUI",
    primary_category_id: Category.where(name: "").first.id,
    secondary_category_id: Category.where(name: "").first.id,
    is_utility: False,
    has_adult_content: false,
    game_id: gameSkyrim.id
)

NexusInfo.create(
    id: 3863,
    mod_id: Mod.last.id,
    uploaded_by: "schlangster",
    authors: "SkyUI Team",
    date_released: DateTime.strptime("17/12/2011 - 12:24AM", nexusDateFormat),
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
    dangerous: false,
)

Mod.create(
    name: "Immersive Armors",
    primary_category_id: Category.where(name: "").first.id,
    secondary_category_id: Category.where(name: "").first.id,
    is_utility: False,
    has_adult_content: false,
    game_id: gameSkyrim.id
)

NexusInfo.create(
    id: 19733,
    mod_id: Mod.last.id,
    uploaded_by: "hothtrooper44",
    authors: "Hothtrooper44",
    date_released: DateTime.strptime("01/07/2012 - 07:23PM", nexusDateFormat),
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
    dangerous: false,
)

Mod.create(
    name: "Skyrim HD - 2K Textures",
    primary_category_id: Category.where(name: "").first.id,
    secondary_category_id: Category.where(name: "").first.id,
    is_utility: False,
    has_adult_content: false,
    game_id: gameSkyrim.id
)

NexusInfo.create(
    id: 607,
    mod_id: Mod.last.id,
    uploaded_by: "NebuLa1",
    authors: "NebuLa from AHBmods",
    date_released: DateTime.strptime("19/11/2011 - 01:03AM", nexusDateFormat),
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
    dangerous: false,
)

Mod.create(
    name: "RaceMenu",
    primary_category_id: Category.where(name: "").first.id,
    secondary_category_id: Category.where(name: "").first.id,
    is_utility: False,
    has_adult_content: false,
    game_id: gameSkyrim.id
)

NexusInfo.create(
    id: 29624,
    mod_id: Mod.last.id,
    uploaded_by: "expired6978",
    authors: "Expired",
    date_released: DateTime.strptime("08/01/2013 - 01:10AM", nexusDateFormat),
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
    dangerous: false,
)

Mod.create(
    name: "Unofficial Skyrim Legendary Edition Patch",
    primary_category_id: Category.where(name: "").first.id,
    secondary_category_id: Category.where(name: "").first.id,
    is_utility: False,
    has_adult_content: false,
    game_id: gameSkyrim.id
)

NexusInfo.create(
    id: 71214,
    mod_id: Mod.last.id,
    uploaded_by: "Arthmoor",
    authors: "Unofficial Patch Project Team ",
    date_released: DateTime.strptime("07/11/2015 - 08:41PM", nexusDateFormat),
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
    dangerous: false,
)

Mod.create(
    name: "Mod Organizer",
    primary_category_id: Category.where(name: "").first.id,
    secondary_category_id: Category.where(name: "").first.id,
    is_utility: True,
    has_adult_content: false,
    game_id: gameSkyrim.id
)

NexusInfo.create(
    id: 1334,
    mod_id: Mod.last.id,
    uploaded_by: "Tannin42",
    authors: "Tannin",
    date_released: DateTime.strptime("24/11/2011 - 03:30PM", nexusDateFormat),
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
    dangerous: false,
)

Mod.create(
    name: "Skyrim Flora Overhaul",
    primary_category_id: Category.where(name: "").first.id,
    secondary_category_id: Category.where(name: "").first.id,
    is_utility: False,
    has_adult_content: false,
    game_id: gameSkyrim.id
)

NexusInfo.create(
    id: 141,
    mod_id: Mod.last.id,
    uploaded_by: "vurt",
    authors: "vurt",
    date_released: DateTime.strptime("13/11/2011 - 10:36PM", nexusDateFormat),
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
    dangerous: false,
)

Mod.create(
    name: "TES5Edit",
    primary_category_id: Category.where(name: "").first.id,
    secondary_category_id: Category.where(name: "").first.id,
    is_utility: True,
    has_adult_content: false,
    game_id: gameSkyrim.id
)

NexusInfo.create(
    id: 25859,
    mod_id: Mod.last.id,
    uploaded_by: "Sharlikran",
    authors: "ElminsterAU",
    date_released: DateTime.strptime("22/10/2012 - 06:22AM", nexusDateFormat),
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
    dangerous: false,
)

Mod.create(
    name: "Merge Plugins",
    primary_category_id: Category.where(name: "").first.id,
    secondary_category_id: Category.where(name: "").first.id,
    is_utility: True,
    has_adult_content: false,
    game_id: gameSkyrim.id
)

NexusInfo.create(
    id: 69905,
    mod_id: Mod.last.id,
    uploaded_by: "matortheeternal",
    authors: "Mator",
    date_released: DateTime.strptime("24/12/2015 - 01:56AM", nexusDateFormat),
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
    dangerous: false,
)

Mod.create(
    name: "The Lily - Armour Mashup",
    primary_category_id: Category.where(name: "").first.id,
    secondary_category_id: Category.where(name: "").first.id,
    is_utility: False,
    has_adult_content: false,
    game_id: gameSkyrim.id
)

NexusInfo.create(
    id: 71843,
    mod_id: Mod.last.id,
    uploaded_by: "pottoply",
    authors: "pottoply",
    date_released: DateTime.strptime("08/12/2015 - 09:42PM", nexusDateFormat),
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
    dangerous: false,
)

Mod.create(
    name: "THE PEOPLE OF SKYRIM ULTIMATE EDITION",
    primary_category_id: Category.where(name: "").first.id,
    secondary_category_id: Category.where(name: "").first.id,
    is_utility: False,
    has_adult_content: false,
    game_id: gameSkyrim.id
)

NexusInfo.create(
    id: 72449,
    mod_id: Mod.last.id,
    uploaded_by: "nesbit098",
    authors: "Nesbit",
    date_released: DateTime.strptime("05/01/2016 - 10:31AM", nexusDateFormat),
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
    dangerous: false,
)

Mod.create(
    name: "Skaal You Need - Skaal house and follower",
    primary_category_id: Category.where(name: "").first.id,
    secondary_category_id: Category.where(name: "").first.id,
    is_utility: False,
    has_adult_content: false,
    game_id: gameSkyrim.id
)

NexusInfo.create(
    id: 72005,
    mod_id: Mod.last.id,
    uploaded_by: "Elianora",
    authors: "Elianora",
    date_released: DateTime.strptime("17/12/2015 - 09:23PM", nexusDateFormat),
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
    dangerous: false,
)

Mod.create(
    name: "SC - Hairstyles",
    primary_category_id: Category.where(name: "").first.id,
    secondary_category_id: Category.where(name: "").first.id,
    is_utility: False,
    has_adult_content: false,
    game_id: gameSkyrim.id
)

NexusInfo.create(
    id: 71561,
    mod_id: Mod.last.id,
    uploaded_by: "ShinglesCat",
    authors: "ShinglesCat",
    date_released: DateTime.strptime("25/11/2015 - 09:21AM", nexusDateFormat),
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
    dangerous: false,
)

Mod.create(
    name: "Real Names",
    primary_category_id: Category.where(name: "").first.id,
    secondary_category_id: Category.where(name: "").first.id,
    is_utility: False,
    has_adult_content: false,
    game_id: gameSkyrim.id
)

NexusInfo.create(
    id: 71464,
    mod_id: Mod.last.id,
    uploaded_by: "nellshini",
    authors: "Jaxonz and Nellshini",
    date_released: DateTime.strptime("23/11/2015 - 02:11AM", nexusDateFormat),
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
    dangerous: false,
)

