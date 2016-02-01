# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160201201851) do

  create_table "agreement_marks", id: false, force: :cascade do |t|
    t.integer "incorrect_note_id", limit: 4
    t.integer "submitted_by",      limit: 4
    t.boolean "agree"
  end

  add_index "agreement_marks", ["incorrect_note_id"], name: "inc_id", using: :btree
  add_index "agreement_marks", ["submitted_by"], name: "submitted_by", using: :btree

  create_table "categories", force: :cascade do |t|
    t.integer "parent_id",   limit: 4
    t.string  "name",        limit: 64
    t.text    "description", limit: 65535
  end

  add_index "categories", ["parent_id"], name: "fk_rails_82f48f7407", using: :btree

  create_table "category_priorities", id: false, force: :cascade do |t|
    t.integer "dominant_id",  limit: 4
    t.integer "recessive_id", limit: 4
  end

  add_index "category_priorities", ["dominant_id"], name: "fk_rails_10799f2958", using: :btree
  add_index "category_priorities", ["recessive_id"], name: "fk_rails_d624be02b9", using: :btree

  create_table "comments", force: :cascade do |t|
    t.integer "parent_comment",   limit: 4
    t.integer "submitted_by",     limit: 4
    t.boolean "hidden"
    t.date    "submitted"
    t.date    "edited"
    t.text    "text_body",        limit: 65535
    t.integer "commentable_id",   limit: 4
    t.string  "commentable_type", limit: 255
  end

  add_index "comments", ["commentable_type", "commentable_id"], name: "index_comments_on_commentable_type_and_commentable_id", using: :btree
  add_index "comments", ["parent_comment"], name: "parent_comment", using: :btree
  add_index "comments", ["submitted_by"], name: "submitted_by", using: :btree

  create_table "compatibility_notes", force: :cascade do |t|
    t.integer "submitted_by",            limit: 4
    t.enum    "mod_mode",                limit: ["Any", "All"]
    t.integer "compatibility_plugin_id", limit: 4
    t.enum    "compatibility_status",    limit: ["Incompatible", "Partially Compatible", "Patch Available", "Make Custom Patch", "Soft Incompatibility", "Installation Note"]
    t.integer "installation_note_id",    limit: 4
    t.date    "submitted"
    t.date    "edited"
    t.text    "text_body",               limit: 65535
  end

  add_index "compatibility_notes", ["compatibility_plugin_id"], name: "compatibility_patch", using: :btree
  add_index "compatibility_notes", ["installation_note_id"], name: "in_id", using: :btree
  add_index "compatibility_notes", ["submitted_by"], name: "submitted_by", using: :btree

  create_table "games", force: :cascade do |t|
    t.string "short_name",    limit: 32
    t.string "long_name",     limit: 128
    t.string "abbr_name",     limit: 32
    t.string "exe_name",      limit: 32
    t.string "steam_app_ids", limit: 64
  end

  create_table "helpful_marks", id: false, force: :cascade do |t|
    t.integer "submitted_by",     limit: 4
    t.boolean "helpful"
    t.integer "helpfulable_id",   limit: 4
    t.string  "helpfulable_type", limit: 255
  end

  add_index "helpful_marks", ["helpfulable_type", "helpfulable_id"], name: "index_helpful_marks_on_helpfulable_type_and_helpfulable_id", using: :btree
  add_index "helpful_marks", ["submitted_by"], name: "submitted_by", using: :btree

  create_table "incorrect_notes", force: :cascade do |t|
    t.integer "submitted_by",     limit: 4
    t.text    "reason",           limit: 65535
    t.integer "correctable_id",   limit: 4
    t.string  "correctable_type", limit: 255
  end

  add_index "incorrect_notes", ["correctable_type", "correctable_id"], name: "index_incorrect_notes_on_correctable_type_and_correctable_id", using: :btree
  add_index "incorrect_notes", ["submitted_by"], name: "submitted_by", using: :btree

  create_table "installation_notes", force: :cascade do |t|
    t.integer "submitted_by",   limit: 4
    t.integer "mod_version_id", limit: 4
    t.boolean "always"
    t.enum    "note_type",      limit: ["Download Option", "FOMOD Option"]
    t.date    "submitted"
    t.date    "edited"
    t.text    "text_body",      limit: 65535
  end

  add_index "installation_notes", ["mod_version_id"], name: "mv_id", using: :btree
  add_index "installation_notes", ["submitted_by"], name: "submitted_by", using: :btree

  create_table "lover_infos", force: :cascade do |t|
    t.integer "mod_id", limit: 4, null: false
  end

  create_table "masters", force: :cascade do |t|
    t.integer "plugin_id", limit: 4
  end

  add_index "masters", ["plugin_id"], name: "pl_id", using: :btree

  create_table "mod_asset_files", force: :cascade do |t|
    t.string "filepath", limit: 128, null: false
  end

  add_index "mod_asset_files", ["filepath"], name: "filepath", unique: true, using: :btree

  create_table "mod_authors", id: false, force: :cascade do |t|
    t.integer "mod_id",  limit: 4
    t.integer "user_id", limit: 4
  end

  add_index "mod_authors", ["mod_id"], name: "mod_id", using: :btree
  add_index "mod_authors", ["user_id"], name: "user_id", using: :btree

  create_table "mod_list_compatibility_notes", id: false, force: :cascade do |t|
    t.integer "mod_list_id",           limit: 4
    t.integer "compatibility_note_id", limit: 4
    t.enum    "status",                limit: ["Resolved", "Ignored"]
  end

  add_index "mod_list_compatibility_notes", ["compatibility_note_id"], name: "cn_id", using: :btree
  add_index "mod_list_compatibility_notes", ["mod_list_id"], name: "ml_id", using: :btree

  create_table "mod_list_custom_plugins", id: false, force: :cascade do |t|
    t.integer "mod_list_id", limit: 4
    t.boolean "active"
    t.integer "load_order",  limit: 2
    t.string  "title",       limit: 64
    t.text    "description", limit: 65535
  end

  add_index "mod_list_custom_plugins", ["mod_list_id"], name: "ml_id", using: :btree

  create_table "mod_list_installation_notes", id: false, force: :cascade do |t|
    t.integer "mod_list_id",          limit: 4
    t.integer "installation_note_id", limit: 4
    t.enum    "status",               limit: ["Resolved", "Ignored"]
  end

  add_index "mod_list_installation_notes", ["installation_note_id"], name: "in_id", using: :btree
  add_index "mod_list_installation_notes", ["mod_list_id"], name: "ml_id", using: :btree

  create_table "mod_list_mods", id: false, force: :cascade do |t|
    t.integer "mod_list_id",   limit: 4
    t.integer "mod_id",        limit: 4
    t.boolean "active"
    t.integer "install_order", limit: 2
  end

  add_index "mod_list_mods", ["mod_id"], name: "mod_id", using: :btree
  add_index "mod_list_mods", ["mod_list_id"], name: "ml_id", using: :btree

  create_table "mod_list_plugins", id: false, force: :cascade do |t|
    t.integer "mod_list_id", limit: 4
    t.integer "plugin_id",   limit: 4
    t.boolean "active"
    t.integer "load_order",  limit: 2
  end

  add_index "mod_list_plugins", ["mod_list_id"], name: "ml_id", using: :btree
  add_index "mod_list_plugins", ["plugin_id"], name: "pl_id", using: :btree

  create_table "mod_list_stars", id: false, force: :cascade do |t|
    t.integer "mod_list_id", limit: 4
    t.integer "user_id",     limit: 4
  end

  add_index "mod_list_stars", ["mod_list_id"], name: "ml_id", using: :btree
  add_index "mod_list_stars", ["user_id"], name: "user_id", using: :btree

  create_table "mod_lists", force: :cascade do |t|
    t.integer "created_by",        limit: 4
    t.boolean "is_collection"
    t.boolean "is_public"
    t.boolean "has_adult_content"
    t.enum    "status",            limit: ["Planned", "Under Construction", "Testing", "Complete"]
    t.date    "created"
    t.date    "completed"
    t.text    "description",       limit: 65535
    t.integer "game_id",           limit: 4,                                                        null: false
  end

  add_index "mod_lists", ["created_by"], name: "created_by", using: :btree
  add_index "mod_lists", ["game_id"], name: "fk_rails_f25cbc0432", using: :btree

  create_table "mod_stars", id: false, force: :cascade do |t|
    t.integer "mod_id",  limit: 4
    t.integer "user_id", limit: 4
  end

  add_index "mod_stars", ["mod_id"], name: "mod_id", using: :btree
  add_index "mod_stars", ["user_id"], name: "user_id", using: :btree

  create_table "mod_version_compatibility_notes", id: false, force: :cascade do |t|
    t.integer "mod_version_id",        limit: 4, null: false
    t.integer "compatibility_note_id", limit: 4, null: false
  end

  add_index "mod_version_compatibility_notes", ["compatibility_note_id"], name: "fk_rails_29b33b572e", using: :btree
  add_index "mod_version_compatibility_notes", ["mod_version_id"], name: "fk_rails_f7085a6344", using: :btree

  create_table "mod_version_files", id: false, force: :cascade do |t|
    t.integer "mod_version_id",    limit: 4
    t.integer "mod_asset_file_id", limit: 4
  end

  add_index "mod_version_files", ["mod_asset_file_id"], name: "maf_id", using: :btree
  add_index "mod_version_files", ["mod_version_id"], name: "mv_id", using: :btree

  create_table "mod_versions", force: :cascade do |t|
    t.integer "mod_id",    limit: 4
    t.date    "released"
    t.boolean "obsolete"
    t.boolean "dangerous"
    t.string  "version",   limit: 16
  end

  add_index "mod_versions", ["mod_id"], name: "mod_id", using: :btree

  create_table "mods", force: :cascade do |t|
    t.string  "name",                  limit: 128
    t.string  "aliases",               limit: 128
    t.boolean "is_utility"
    t.boolean "has_adult_content"
    t.integer "game_id",               limit: 4
    t.integer "primary_category_id",   limit: 4
    t.integer "secondary_category_id", limit: 4
    t.integer "user_stars_count",      limit: 4
    t.integer "reviews_count",         limit: 4
    t.integer "comments_count",        limit: 4
    t.integer "mod_versions_count",    limit: 4
  end

  add_index "mods", ["game_id"], name: "fk_rails_3ec448a848", using: :btree
  add_index "mods", ["primary_category_id"], name: "fk_rails_42759f5da5", using: :btree
  add_index "mods", ["secondary_category_id"], name: "fk_rails_26f394ea9d", using: :btree

  create_table "nexus_infos", force: :cascade do |t|
    t.string  "uploaded_by",      limit: 128
    t.string  "authors",          limit: 128
    t.date    "date_released"
    t.date    "date_updated"
    t.integer "endorsements",     limit: 4
    t.integer "total_downloads",  limit: 4
    t.integer "unique_downloads", limit: 4
    t.integer "views",            limit: 8
    t.integer "posts_count",      limit: 4
    t.integer "videos_count",     limit: 2
    t.integer "images_count",     limit: 2
    t.integer "files_count",      limit: 2
    t.integer "articles_count",   limit: 2
    t.integer "nexus_category",   limit: 2
    t.text    "changelog",        limit: 65535
    t.integer "mod_id",           limit: 4,     null: false
  end

  create_table "override_records", id: false, force: :cascade do |t|
    t.integer "plugin_id", limit: 4
    t.integer "master_id", limit: 4
    t.integer "form_id",   limit: 4
    t.string  "sig",       limit: 4
  end

  add_index "override_records", ["master_id"], name: "mst_id", using: :btree
  add_index "override_records", ["plugin_id"], name: "pl_id", using: :btree

  create_table "plugin_record_groups", id: false, force: :cascade do |t|
    t.integer "plugin_id",        limit: 4
    t.string  "sig",              limit: 4
    t.integer "new_records",      limit: 4
    t.integer "override_records", limit: 4
  end

  add_index "plugin_record_groups", ["plugin_id"], name: "pl_id", using: :btree

  create_table "plugins", force: :cascade do |t|
    t.integer "mod_version_id", limit: 4
    t.string  "filename",       limit: 64
    t.string  "author",         limit: 128
    t.string  "description",    limit: 512
    t.string  "crc_hash",       limit: 8
  end

  add_index "plugins", ["mod_version_id"], name: "mv_id", using: :btree

  create_table "record_groups", force: :cascade do |t|
    t.integer "game_id",     limit: 4
    t.string  "signature",   limit: 4
    t.string  "name",        limit: 64
    t.boolean "child_group"
  end

  add_index "record_groups", ["game_id", "signature"], name: "index_record_groups_on_game_id_and_signature", unique: true, using: :btree

  create_table "reputation_links", id: false, force: :cascade do |t|
    t.integer "from_rep_id", limit: 4
    t.integer "to_rep_id",   limit: 4
  end

  add_index "reputation_links", ["from_rep_id"], name: "from_rep_id", using: :btree
  add_index "reputation_links", ["to_rep_id"], name: "to_rep_id", using: :btree

  create_table "reviews", force: :cascade do |t|
    t.integer "submitted_by", limit: 4
    t.integer "mod_id",       limit: 4
    t.boolean "hidden"
    t.integer "rating1",      limit: 1
    t.integer "rating2",      limit: 1
    t.integer "rating3",      limit: 1
    t.integer "rating4",      limit: 1
    t.integer "rating5",      limit: 1
    t.date    "submitted"
    t.date    "edited"
    t.text    "text_body",    limit: 65535
  end

  add_index "reviews", ["mod_id"], name: "mod_id", using: :btree
  add_index "reviews", ["submitted_by"], name: "submitted_by", using: :btree

  create_table "user_bios", force: :cascade do |t|
    t.string  "nexus_username", limit: 32
    t.boolean "nexus_verified"
    t.string  "lover_username", limit: 32
    t.boolean "lover_verified"
    t.string  "steam_username", limit: 32
    t.boolean "steam_verified"
    t.integer "user_id",        limit: 4
  end

  add_index "user_bios", ["user_id"], name: "user_id", using: :btree

  create_table "user_reputations", force: :cascade do |t|
    t.float   "overall",            limit: 24
    t.float   "offset",             limit: 24
    t.float   "audiovisual_design", limit: 24
    t.float   "plugin_design",      limit: 24
    t.float   "utility_design",     limit: 24
    t.float   "script_design",      limit: 24
    t.integer "user_id",            limit: 4
  end

  add_index "user_reputations", ["user_id"], name: "user_id", using: :btree

  create_table "user_settings", force: :cascade do |t|
    t.boolean "show_notifications"
    t.boolean "show_tooltips"
    t.boolean "email_notifications"
    t.boolean "email_public"
    t.boolean "allow_adult_content"
    t.boolean "allow_nexus_mods"
    t.boolean "allow_lovers_lab"
    t.boolean "allow_steam_workshop"
    t.integer "user_id",              limit: 4
    t.string  "timezone",             limit: 128
    t.string  "udate_format",         limit: 128
    t.string  "utime_format",         limit: 128
  end

  add_index "user_settings", ["user_id"], name: "user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "username",               limit: 32
    t.enum     "user_level",             limit: ["guest", "banned", "user", "author", "vip", "moderator", "admin"]
    t.string   "title",                  limit: 32
    t.string   "avatar",                 limit: 128
    t.date     "joined"
    t.integer  "active_ml_id",           limit: 4
    t.integer  "active_mc_id",           limit: 4
    t.string   "email",                  limit: 255,                                                                default: "", null: false
    t.string   "encrypted_password",     limit: 255,                                                                default: "", null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,                                                                  default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.string   "confirmation_token",     limit: 255
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
  end

  add_index "users", ["active_mc_id"], name: "active_mc_id", using: :btree
  add_index "users", ["active_ml_id"], name: "active_ml_id", using: :btree
  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "workshop_infos", force: :cascade do |t|
    t.integer "mod_id", limit: 4, null: false
  end
  
  # convert id columns to unsigned integers
  execute("ALTER TABLE agreement_marks MODIFY incorrect_note_id INT UNSIGNED;")
  execute("ALTER TABLE agreement_marks MODIFY submitted_by INT UNSIGNED;")

  execute("ALTER TABLE categories MODIFY id INT UNSIGNED NOT NULL AUTO_INCREMENT;")
  execute("ALTER TABLE categories MODIFY parent_id INT UNSIGNED;")

  execute("ALTER TABLE category_priorities MODIFY dominant_id INT UNSIGNED;")
  execute("ALTER TABLE category_priorities MODIFY recessive_id INT UNSIGNED;")

  execute("ALTER TABLE comments MODIFY id INT UNSIGNED NOT NULL AUTO_INCREMENT;")
  execute("ALTER TABLE comments MODIFY submitted_by INT UNSIGNED;")
  execute("ALTER TABLE comments MODIFY parent_comment INT UNSIGNED;")
  execute("ALTER TABLE comments MODIFY commentable_id INT UNSIGNED;")

  execute("ALTER TABLE compatibility_notes MODIFY id INT UNSIGNED NOT NULL AUTO_INCREMENT;")
  execute("ALTER TABLE compatibility_notes MODIFY submitted_by INT UNSIGNED;")
  execute("ALTER TABLE compatibility_notes MODIFY compatibility_plugin_id INT UNSIGNED;")
  execute("ALTER TABLE compatibility_notes MODIFY installation_note_id INT UNSIGNED;")

  execute("ALTER TABLE games MODIFY id INT UNSIGNED NOT NULL AUTO_INCREMENT;")

  execute("ALTER TABLE helpful_marks MODIFY submitted_by INT UNSIGNED;")
  execute("ALTER TABLE helpful_marks MODIFY helpfulable_id INT UNSIGNED;")

  execute("ALTER TABLE incorrect_notes MODIFY id INT UNSIGNED NOT NULL AUTO_INCREMENT;")
  execute("ALTER TABLE incorrect_notes MODIFY submitted_by INT UNSIGNED;")
  execute("ALTER TABLE incorrect_notes MODIFY correctable_id INT UNSIGNED")

  execute("ALTER TABLE installation_notes MODIFY id INT UNSIGNED NOT NULL AUTO_INCREMENT;")
  execute("ALTER TABLE installation_notes MODIFY submitted_by INT UNSIGNED;")
  execute("ALTER TABLE installation_notes MODIFY mod_version_id INT UNSIGNED;")

  execute("ALTER TABLE lover_infos MODIFY id INT UNSIGNED NOT NULL AUTO_INCREMENT;")
  execute("ALTER TABLE lover_infos MODIFY mod_id INT UNSIGNED;")

  execute("ALTER TABLE masters MODIFY id INT UNSIGNED NOT NULL AUTO_INCREMENT;")
  execute("ALTER TABLE masters MODIFY plugin_id INT UNSIGNED;")
  
  execute("ALTER TABLE mod_asset_files MODIFY id INT UNSIGNED NOT NULL AUTO_INCREMENT;")

  execute("ALTER TABLE mod_authors MODIFY mod_id INT UNSIGNED;")
  execute("ALTER TABLE mod_authors MODIFY user_id INT UNSIGNED;")

  execute("ALTER TABLE mod_list_compatibility_notes MODIFY mod_list_id INT UNSIGNED;")
  execute("ALTER TABLE mod_list_compatibility_notes MODIFY compatibility_note_id INT UNSIGNED;")

  execute("ALTER TABLE mod_list_custom_plugins MODIFY mod_list_id INT UNSIGNED;")

  execute("ALTER TABLE mod_list_installation_notes MODIFY mod_list_id INT UNSIGNED;")
  execute("ALTER TABLE mod_list_installation_notes MODIFY installation_note_id INT UNSIGNED;")

  execute("ALTER TABLE mod_list_mods MODIFY mod_list_id INT UNSIGNED;")
  execute("ALTER TABLE mod_list_mods MODIFY mod_id INT UNSIGNED;")

  execute("ALTER TABLE mod_list_plugins MODIFY mod_list_id INT UNSIGNED;")
  execute("ALTER TABLE mod_list_plugins MODIFY plugin_id INT UNSIGNED;")

  execute("ALTER TABLE mod_list_stars MODIFY mod_list_id INT UNSIGNED;")
  execute("ALTER TABLE mod_list_stars MODIFY user_id INT UNSIGNED;")

  execute("ALTER TABLE mod_lists MODIFY id INT UNSIGNED NOT NULL AUTO_INCREMENT;")
  execute("ALTER TABLE mod_lists MODIFY created_by INT UNSIGNED;")
  execute("ALTER TABLE mod_lists MODIFY game_id INT UNSIGNED;")

  execute("ALTER TABLE mod_stars MODIFY mod_id INT UNSIGNED;")
  execute("ALTER TABLE mod_stars MODIFY user_id INT UNSIGNED;")

  execute("ALTER TABLE mod_version_compatibility_notes MODIFY mod_version_id INT UNSIGNED;")
  execute("ALTER TABLE mod_version_compatibility_notes MODIFY compatibility_note_id INT UNSIGNED;")

  execute("ALTER TABLE mod_version_files MODIFY mod_version_id INT UNSIGNED;")
  execute("ALTER TABLE mod_version_files MODIFY mod_asset_file_id INT UNSIGNED;")

  execute("ALTER TABLE mod_versions MODIFY id INT UNSIGNED NOT NULL AUTO_INCREMENT;")
  execute("ALTER TABLE mod_versions MODIFY mod_id INT UNSIGNED;")

  execute("ALTER TABLE mods MODIFY id INT UNSIGNED NOT NULL AUTO_INCREMENT;")
  execute("ALTER TABLE mods MODIFY game_id INT UNSIGNED;")
  execute("ALTER TABLE mods MODIFY primary_category_id INT UNSIGNED;")
  execute("ALTER TABLE mods MODIFY secondary_category_id INT UNSIGNED;")

  execute("ALTER TABLE nexus_infos MODIFY id INT UNSIGNED NOT NULL AUTO_INCREMENT;")
  execute("ALTER TABLE nexus_infos MODIFY mod_id INT UNSIGNED;")

  execute("ALTER TABLE override_records MODIFY plugin_id INT UNSIGNED;")
  execute("ALTER TABLE override_records MODIFY master_id INT UNSIGNED;")

  execute("ALTER TABLE plugin_record_groups MODIFY plugin_id INT UNSIGNED;")

  execute("ALTER TABLE plugins MODIFY id INT UNSIGNED NOT NULL AUTO_INCREMENT;")
  execute("ALTER TABLE plugins MODIFY mod_version_id INT UNSIGNED;")

  execute("ALTER TABLE record_groups MODIFY id INT UNSIGNED NOT NULL AUTO_INCREMENT;")
  execute("ALTER TABLE record_groups MODIFY game_id INT UNSIGNED;")

  execute("ALTER TABLE reputation_links MODIFY from_rep_id INT UNSIGNED;")
  execute("ALTER TABLE reputation_links MODIFY to_rep_id INT UNSIGNED;")

  execute("ALTER TABLE reviews MODIFY id INT UNSIGNED NOT NULL AUTO_INCREMENT;")
  execute("ALTER TABLE reviews MODIFY submitted_by INT UNSIGNED;")
  execute("ALTER TABLE reviews MODIFY mod_id INT UNSIGNED;")

  execute("ALTER TABLE user_bios MODIFY id INT UNSIGNED NOT NULL AUTO_INCREMENT;")
  execute("ALTER TABLE user_bios MODIFY user_id INT UNSIGNED;")

  execute("ALTER TABLE user_reputations MODIFY id INT UNSIGNED NOT NULL AUTO_INCREMENT;")
  execute("ALTER TABLE user_reputations MODIFY user_id INT UNSIGNED;")

  execute("ALTER TABLE user_settings MODIFY id INT UNSIGNED NOT NULL AUTO_INCREMENT;")
  execute("ALTER TABLE user_settings MODIFY user_id INT UNSIGNED;")

  execute("ALTER TABLE users MODIFY id INT UNSIGNED NOT NULL AUTO_INCREMENT;")
  execute("ALTER TABLE users MODIFY active_ml_id INT UNSIGNED;")
  execute("ALTER TABLE users MODIFY active_mc_id INT UNSIGNED;")

  execute("ALTER TABLE workshop_infos MODIFY id INT UNSIGNED NOT NULL AUTO_INCREMENT;")
  execute("ALTER TABLE workshop_infos MODIFY mod_id INT UNSIGNED;")
	
  # foreign keys
  add_foreign_key "agreement_marks", "incorrect_notes", name: "agreement_marks_ibfk_1"
  add_foreign_key "agreement_marks", "users", column: "submitted_by", name: "agreement_marks_ibfk_2"
  add_foreign_key "categories", "categories", column: "parent_id"
  add_foreign_key "category_priorities", "categories", column: "dominant_id"
  add_foreign_key "category_priorities", "categories", column: "recessive_id"
  add_foreign_key "comments", "comments", column: "parent_comment", name: "comments_ibfk_1"
  add_foreign_key "comments", "users", column: "submitted_by", name: "comments_ibfk_2"
  add_foreign_key "compatibility_notes", "installation_notes", name: "compatibility_notes_ibfk_3"
  add_foreign_key "compatibility_notes", "plugins", column: "compatibility_plugin_id", name: "compatibility_notes_ibfk_2"
  add_foreign_key "compatibility_notes", "users", column: "submitted_by", name: "compatibility_notes_ibfk_1"
  add_foreign_key "helpful_marks", "users", column: "submitted_by", name: "helpful_marks_ibfk_4"
  add_foreign_key "incorrect_notes", "users", column: "submitted_by", name: "incorrect_notes_ibfk_4"
  add_foreign_key "installation_notes", "mod_versions", name: "installation_notes_ibfk_2"
  add_foreign_key "installation_notes", "users", column: "submitted_by", name: "installation_notes_ibfk_1"
  add_foreign_key "masters", "plugins", name: "masters_ibfk_1"
  add_foreign_key "mod_authors", "mods", name: "mod_authors_ibfk_1"
  add_foreign_key "mod_authors", "users", name: "mod_authors_ibfk_2"
  add_foreign_key "mod_list_compatibility_notes", "compatibility_notes", name: "mod_list_compatibility_notes_ibfk_2"
  add_foreign_key "mod_list_compatibility_notes", "mod_lists", name: "mod_list_compatibility_notes_ibfk_1"
  add_foreign_key "mod_list_custom_plugins", "mod_lists", name: "mod_list_custom_plugins_ibfk_1"
  add_foreign_key "mod_list_installation_notes", "installation_notes", name: "mod_list_installation_notes_ibfk_2"
  add_foreign_key "mod_list_installation_notes", "mod_lists", name: "mod_list_installation_notes_ibfk_1"
  add_foreign_key "mod_list_mods", "mod_lists", name: "mod_list_mods_ibfk_1"
  add_foreign_key "mod_list_mods", "mods", name: "mod_list_mods_ibfk_2"
  add_foreign_key "mod_list_plugins", "mod_lists", name: "mod_list_plugins_ibfk_1"
  add_foreign_key "mod_list_plugins", "plugins", name: "mod_list_plugins_ibfk_2"
  add_foreign_key "mod_list_stars", "mod_lists", name: "mod_list_stars_ibfk_1"
  add_foreign_key "mod_list_stars", "users", name: "mod_list_stars_ibfk_2"
  add_foreign_key "mod_lists", "games"
  add_foreign_key "mod_lists", "users", column: "created_by", name: "mod_lists_ibfk_1"
  add_foreign_key "mod_stars", "mods", name: "mod_stars_ibfk_1"
  add_foreign_key "mod_stars", "users", name: "mod_stars_ibfk_2"
  add_foreign_key "mod_version_compatibility_notes", "compatibility_notes"
  add_foreign_key "mod_version_compatibility_notes", "mod_versions"
  add_foreign_key "mod_version_files", "mod_asset_files", name: "mod_version_files_ibfk_2"
  add_foreign_key "mod_version_files", "mod_versions", name: "mod_version_files_ibfk_1"
  add_foreign_key "mod_versions", "mods", name: "mod_versions_ibfk_1"
  add_foreign_key "mods", "categories", column: "primary_category_id"
  add_foreign_key "mods", "categories", column: "secondary_category_id"
  add_foreign_key "mods", "games"
  add_foreign_key "override_records", "masters", name: "override_records_ibfk_2"
  add_foreign_key "override_records", "plugins", name: "override_records_ibfk_1"
  add_foreign_key "plugin_record_groups", "plugins", name: "plugin_record_groups_ibfk_1"
  add_foreign_key "plugins", "mod_versions", name: "plugins_ibfk_1"
  add_foreign_key "record_groups", "games"
  add_foreign_key "reputation_links", "user_reputations", column: "from_rep_id", name: "reputation_links_ibfk_1"
  add_foreign_key "reputation_links", "user_reputations", column: "to_rep_id", name: "reputation_links_ibfk_2"
  add_foreign_key "reviews", "mods", name: "reviews_ibfk_2"
  add_foreign_key "reviews", "users", column: "submitted_by", name: "reviews_ibfk_1"
  add_foreign_key "user_bios", "users", name: "user_bios_ibfk_1"
  add_foreign_key "user_reputations", "users", name: "user_reputations_ibfk_1"
  add_foreign_key "user_settings", "users", name: "user_settings_ibfk_1"
  add_foreign_key "users", "mod_lists", column: "active_mc_id", name: "users_ibfk_5"
  add_foreign_key "users", "mod_lists", column: "active_ml_id", name: "users_ibfk_4"
end
