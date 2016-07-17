#==================================================
# CREATE STATIC RECORDS
#==================================================

require_relative  'static_seeds'

static_config = {
    staff: true,
    games: true,
    categories: true,
    quotes: true,
    user_titles: true,
    record_groups: true,
    official_content: true
}

seed_staff_users if static_config[:staff]
seed_games if static_config[:games]
seed_categories if static_config[:categories]
seed_quotes if static_config[:quotes]
seed_user_titles if static_config[:user_titles]
seed_record_groups if static_config[:record_groups]
seed_official_content if static_config[:official_content]

#==================================================
# CREATE FAKE RECORDS
#==================================================
require_relative 'fake_seeds'

fake_config = {
    users: true,
    mods: false,
    comments: true,
    reviews: true,
    cnotes: true,
    inotes: true,
    lnotes: false,
    mod_authors: false,
    mod_lists: true,
    tags: false,
    articles: false
}

seed_fake_users if fake_config[:users]
seed_fake_mods if fake_config[:mods]
seed_fake_comments if fake_config[:comments]
seed_fake_reviews if fake_config[:reviews]
seed_fake_compatibility_notes if fake_config[:cnotes]
seed_fake_install_order_notes if fake_config[:inotes]
seed_fake_load_order_notes if fake_config[:lnotes]
seed_fake_mod_authors if fake_config[:mod_authors]
seed_fake_mod_lists if fake_config[:mod_lists]
seed_fake_tags if fake_config[:tags]
seed_fake_articles if fake_config[:articles]
