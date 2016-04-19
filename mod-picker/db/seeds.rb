#==================================================
# CONFIGURATION OPTIONS
#==================================================

bSeedUsers = true
bSeedComments = true
bSeedReviews = true
bSeedCNotes = true
bSeedINotes = true
bSeedLNotes = false
bSeedModAuthors = true
bSeedMods = true
bSeedModLists = true
bSeedTags = true

#==================================================
# CREATE STATIC RECORDS
#==================================================

require_relative  'static_seeds'
seed_static_records

#==================================================
# CREATE FAKE RECORDS
#==================================================

require_relative 'fake_seeds'
seed_fake_mods if bSeedMods
seed_fake_users if bSeedUsers
seed_fake_comments if bSeedComments
seed_fake_reviews if bSeedReviews
seed_fake_compatibility_notes if bSeedCNotes
seed_fake_install_order_notes if bSeedINotes
seed_fake_load_order_notes if bSeedLNotes
seed_fake_mod_authors if bSeedModAuthors
seed_fake_mod_lists if bSeedModLists
seed_fake_tags if bSeedTags
