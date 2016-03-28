#==================================================
# CONFIGURATION OPTIONS
#==================================================

bSeedUsers = true
bSeedComments = true
bSeedReviews = true
bSeedCNotes = true
bSeedINotes = true
bSeedModAuthors = true
bSeedFakeMods = true
bSeedModLists = true

#==================================================
# CREATE STATIC RECORDS
#==================================================

require_relative  'static_seeds'
seed_static_records

#==================================================
# CREATE FAKE RECORDS
#==================================================

require_relative 'fake_seeds'
seed_fake_users if bSeedUsers
seed_fake_comments if bSeedComments
seed_fake_reviews if bSeedReviews
seed_fake_compatibility_notes if bSeedCNotes
seed_fake_installation_notes if bSeedINotes
seed_fake_mod_authors if bSeedModAuthors
seed_fake_mods if bSeedFakeMods
seed_fake_mod_lists if bSeedModLists