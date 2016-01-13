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

ActiveRecord::Schema.define(version: 20160112015243) do

  create_table "agreement_marks", id: false, force: :cascade do |t|
    t.integer "inc_id",       limit: 4
    t.integer "submitted_by", limit: 4
    t.boolean "agree"
  end

  add_index "agreement_marks", ["inc_id"], name: "inc_id", using: :btree
  add_index "agreement_marks", ["submitted_by"], name: "submitted_by", using: :btree

  create_table "comments", primary_key: "c_id", force: :cascade do |t|
    t.integer "parent_comment", limit: 4
    t.integer "submitted_by",   limit: 4
    t.boolean "hidden"
    t.date    "submitted"
    t.date    "edited"
    t.text    "text_body",      limit: 65535
  end

  add_index "comments", ["parent_comment"], name: "parent_comment", using: :btree
  add_index "comments", ["submitted_by"], name: "submitted_by", using: :btree

  create_table "compatibility_notes", primary_key: "cn_id", force: :cascade do |t|
    t.integer "submitted_by",         limit: 4
    t.enum    "mod_mode",             limit: ["Any", "All"]
    t.integer "compatibility_patch",  limit: 4
    t.enum    "compatibility_status", limit: ["Incompatible", "Partially Compatible", "Patch Available", "Make Custom Patch", "Soft Incompatibility", "Installation Note"]
    t.integer "in_id",                limit: 4
    t.date    "submitted"
    t.date    "edited"
    t.text    "text_body",            limit: 65535
  end

  add_index "compatibility_notes", ["compatibility_patch"], name: "compatibility_patch", using: :btree
  add_index "compatibility_notes", ["in_id"], name: "in_id", using: :btree
  add_index "compatibility_notes", ["submitted_by"], name: "submitted_by", using: :btree

  create_table "helpful_marks", id: false, force: :cascade do |t|
    t.integer "r_id",         limit: 4
    t.integer "cn_id",        limit: 4
    t.integer "in_id",        limit: 4
    t.integer "submitted_by", limit: 4
    t.boolean "helpful"
  end

  add_index "helpful_marks", ["cn_id"], name: "cn_id", using: :btree
  add_index "helpful_marks", ["in_id"], name: "in_id", using: :btree
  add_index "helpful_marks", ["r_id"], name: "r_id", using: :btree
  add_index "helpful_marks", ["submitted_by"], name: "submitted_by", using: :btree

  create_table "incorrect_notes", primary_key: "inc_id", force: :cascade do |t|
    t.integer "r_id",         limit: 4
    t.integer "cn_id",        limit: 4
    t.integer "in_id",        limit: 4
    t.integer "submitted_by", limit: 4
    t.text    "reason",       limit: 65535
  end

  add_index "incorrect_notes", ["cn_id"], name: "cn_id", using: :btree
  add_index "incorrect_notes", ["in_id"], name: "in_id", using: :btree
  add_index "incorrect_notes", ["r_id"], name: "r_id", using: :btree
  add_index "incorrect_notes", ["submitted_by"], name: "submitted_by", using: :btree

  create_table "installation_notes", primary_key: "in_id", force: :cascade do |t|
    t.integer "submitted_by", limit: 4
    t.integer "mv_id",        limit: 4
    t.boolean "always"
    t.enum    "note_type",    limit: ["Download Option", "FOMOD Option"]
    t.date    "submitted"
    t.date    "edited"
    t.text    "text_body",    limit: 65535
  end

  add_index "installation_notes", ["mv_id"], name: "mv_id", using: :btree
  add_index "installation_notes", ["submitted_by"], name: "submitted_by", using: :btree

  create_table "lover_infos", primary_key: "ll_id", force: :cascade do |t|
  end

  create_table "masters", primary_key: "mst_id", force: :cascade do |t|
    t.integer "pl_id", limit: 4
  end

  add_index "masters", ["pl_id"], name: "pl_id", using: :btree

  create_table "mod_asset_files", primary_key: "maf_id", force: :cascade do |t|
    t.string "filepath", limit: 128, null: false
  end

  add_index "mod_asset_files", ["filepath"], name: "filepath", unique: true, using: :btree

  create_table "mod_comments", id: false, force: :cascade do |t|
    t.integer "mod_id", limit: 4
    t.integer "c_id",   limit: 4
  end

  add_index "mod_comments", ["c_id"], name: "c_id", using: :btree
  add_index "mod_comments", ["mod_id"], name: "mod_id", using: :btree

  create_table "mod_list_comments", id: false, force: :cascade do |t|
    t.integer "ml_id", limit: 4
    t.integer "c_id",  limit: 4
  end

  add_index "mod_list_comments", ["c_id"], name: "c_id", using: :btree
  add_index "mod_list_comments", ["ml_id"], name: "ml_id", using: :btree

  create_table "mod_list_compatibility_notes", id: false, force: :cascade do |t|
    t.integer "ml_id",  limit: 4
    t.integer "cn_id",  limit: 4
    t.enum    "status", limit: ["Resolved", "Ignored"]
  end

  add_index "mod_list_compatibility_notes", ["cn_id"], name: "cn_id", using: :btree
  add_index "mod_list_compatibility_notes", ["ml_id"], name: "ml_id", using: :btree

  create_table "mod_list_custom_plugins", id: false, force: :cascade do |t|
    t.integer "ml_id",       limit: 4
    t.boolean "active"
    t.integer "load_order",  limit: 2
    t.string  "title",       limit: 64
    t.text    "description", limit: 65535
  end

  add_index "mod_list_custom_plugins", ["ml_id"], name: "ml_id", using: :btree

  create_table "mod_list_installation_notes", id: false, force: :cascade do |t|
    t.integer "ml_id",  limit: 4
    t.integer "in_id",  limit: 4
    t.enum    "status", limit: ["Resolved", "Ignored"]
  end

  add_index "mod_list_installation_notes", ["in_id"], name: "in_id", using: :btree
  add_index "mod_list_installation_notes", ["ml_id"], name: "ml_id", using: :btree

  create_table "mod_list_mods", id: false, force: :cascade do |t|
    t.integer "ml_id",         limit: 4
    t.integer "mod_id",        limit: 4
    t.boolean "active"
    t.integer "install_order", limit: 2
  end

  add_index "mod_list_mods", ["ml_id"], name: "ml_id", using: :btree
  add_index "mod_list_mods", ["mod_id"], name: "mod_id", using: :btree

  create_table "mod_list_plugins", id: false, force: :cascade do |t|
    t.integer "ml_id",      limit: 4
    t.integer "pl_id",      limit: 4
    t.boolean "active"
    t.integer "load_order", limit: 2
  end

  add_index "mod_list_plugins", ["ml_id"], name: "ml_id", using: :btree
  add_index "mod_list_plugins", ["pl_id"], name: "pl_id", using: :btree

  create_table "mod_lists", primary_key: "ml_id", force: :cascade do |t|
    t.text    "game",              limit: 255
    t.integer "created_by",        limit: 4
    t.boolean "is_collection"
    t.boolean "is_public"
    t.boolean "has_adult_content"
    t.enum    "status",            limit: ["Planned", "Under Construction", "Testing", "Complete"]
    t.date    "created"
    t.date    "completed"
    t.text    "description",       limit: 65535
  end

  add_index "mod_lists", ["created_by"], name: "created_by", using: :btree

  create_table "mod_version_file_map", id: false, force: :cascade do |t|
    t.integer "mv_id",  limit: 4
    t.integer "maf_id", limit: 4
  end

  add_index "mod_version_file_map", ["maf_id"], name: "maf_id", using: :btree
  add_index "mod_version_file_map", ["mv_id"], name: "mv_id", using: :btree

  create_table "mod_versions", primary_key: "mv_id", force: :cascade do |t|
    t.integer "mod_id",      limit: 4
    t.integer "nxm_file_id", limit: 4
    t.date    "released"
    t.boolean "obsolete"
    t.boolean "dangerous"
  end

  add_index "mod_versions", ["mod_id"], name: "mod_id", using: :btree

  create_table "mods", primary_key: "mod_id", force: :cascade do |t|
    t.text    "game",              limit: 255
    t.text    "name",              limit: 255
    t.text    "aliases",           limit: 255
    t.boolean "is_utility"
    t.integer "category",          limit: 2
    t.boolean "has_adult_content"
    t.integer "nm_id",             limit: 4
    t.integer "ws_id",             limit: 4
    t.integer "ll_id",             limit: 4
  end

  add_index "mods", ["ll_id"], name: "ll_id", using: :btree
  add_index "mods", ["nm_id"], name: "nm_id", using: :btree
  add_index "mods", ["ws_id"], name: "ws_id", using: :btree

  create_table "nexus_infos", primary_key: "nm_id", force: :cascade do |t|
    t.text    "uploaded_by",      limit: 255
    t.text    "authors",          limit: 255
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
  end

  create_table "plugin_override_map", id: false, force: :cascade do |t|
    t.integer "pl_id",   limit: 4
    t.integer "mst_id",  limit: 4
    t.integer "form_id", limit: 4
    t.string  "sig",     limit: 4
    t.text    "name",    limit: 255
    t.boolean "is_itm"
    t.boolean "is_itpo"
    t.boolean "is_udr"
  end

  add_index "plugin_override_map", ["mst_id"], name: "mst_id", using: :btree
  add_index "plugin_override_map", ["pl_id"], name: "pl_id", using: :btree

  create_table "plugin_record_groups", id: false, force: :cascade do |t|
    t.integer "pl_id",            limit: 4
    t.string  "sig",              limit: 4
    t.text    "name",             limit: 255
    t.integer "new_records",      limit: 4
    t.integer "override_records", limit: 4
  end

  add_index "plugin_record_groups", ["pl_id"], name: "pl_id", using: :btree

  create_table "plugins", primary_key: "pl_id", force: :cascade do |t|
    t.integer "mv_id",       limit: 4
    t.text    "filename",    limit: 255
    t.text    "author",      limit: 255
    t.text    "description", limit: 65535
    t.string  "crc_hash",    limit: 8
  end

  add_index "plugins", ["mv_id"], name: "mv_id", using: :btree

  create_table "reputation_map", id: false, force: :cascade do |t|
    t.integer "from_rep_id", limit: 4
    t.integer "to_rep_id",   limit: 4
  end

  add_index "reputation_map", ["from_rep_id"], name: "from_rep_id", using: :btree
  add_index "reputation_map", ["to_rep_id"], name: "to_rep_id", using: :btree

  create_table "reviews", primary_key: "r_id", force: :cascade do |t|
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

  create_table "user_bios", primary_key: "bio_id", force: :cascade do |t|
    t.string  "nexus_username", limit: 32
    t.boolean "nexus_verified"
    t.string  "lover_username", limit: 32
    t.boolean "lover_verified"
    t.string  "steam_username", limit: 32
    t.boolean "steam_verified"
    t.integer "user_id",        limit: 4
  end

  add_index "user_bios", ["user_id"], name: "user_id", using: :btree

  create_table "user_comments", id: false, force: :cascade do |t|
    t.integer "user_id", limit: 4
    t.integer "c_id",    limit: 4
  end

  add_index "user_comments", ["c_id"], name: "c_id", using: :btree
  add_index "user_comments", ["user_id"], name: "user_id", using: :btree

  create_table "user_mod_author_map", id: false, force: :cascade do |t|
    t.integer "mod_id",  limit: 4
    t.integer "user_id", limit: 4
  end

  add_index "user_mod_author_map", ["mod_id"], name: "mod_id", using: :btree
  add_index "user_mod_author_map", ["user_id"], name: "user_id", using: :btree

  create_table "user_mod_list_star_map", id: false, force: :cascade do |t|
    t.integer "ml_id",   limit: 4
    t.integer "user_id", limit: 4
  end

  add_index "user_mod_list_star_map", ["ml_id"], name: "ml_id", using: :btree
  add_index "user_mod_list_star_map", ["user_id"], name: "user_id", using: :btree

  create_table "user_mod_star_map", id: false, force: :cascade do |t|
    t.integer "mod_id",  limit: 4
    t.integer "user_id", limit: 4
  end

  add_index "user_mod_star_map", ["mod_id"], name: "mod_id", using: :btree
  add_index "user_mod_star_map", ["user_id"], name: "user_id", using: :btree

  create_table "user_reputations", primary_key: "rep_id", force: :cascade do |t|
    t.float   "overall",            limit: 24
    t.float   "offset",             limit: 24
    t.float   "audiovisual_design", limit: 24
    t.float   "plugin_design",      limit: 24
    t.float   "utility_design",     limit: 24
    t.float   "script_design",      limit: 24
    t.integer "user_id",            limit: 4
  end

  add_index "user_reputations", ["user_id"], name: "user_id", using: :btree

  create_table "user_settings", primary_key: "set_id", force: :cascade do |t|
    t.boolean "show_notifications"
    t.boolean "show_tooltips"
    t.boolean "email_notifications"
    t.boolean "email_public"
    t.boolean "allow_adult_content"
    t.boolean "allow_nexus_mods"
    t.boolean "allow_lovers_lab"
    t.boolean "allow_steam_workshop"
    t.integer "user_id",              limit: 4
  end

  add_index "user_settings", ["user_id"], name: "user_id", using: :btree

  create_table "users", primary_key: "user_id", force: :cascade do |t|
    t.string   "username",               limit: 32
    t.enum     "user_level",             limit: ["guest", "banned", "user", "author", "vip", "moderator", "admin"]
    t.string   "title",                  limit: 32
    t.text     "avatar",                 limit: 255
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

  create_table "workshop_infos", primary_key: "ws_id", force: :cascade do |t|
  end

  add_foreign_key "agreement_marks", "incorrect_notes", column: "inc_id", primary_key: "inc_id", name: "agreement_marks_ibfk_1"
  add_foreign_key "agreement_marks", "users", column: "submitted_by", primary_key: "user_id", name: "agreement_marks_ibfk_2"
  add_foreign_key "comments", "comments", column: "parent_comment", primary_key: "c_id", name: "comments_ibfk_1"
  add_foreign_key "comments", "users", column: "submitted_by", primary_key: "user_id", name: "comments_ibfk_2"
  add_foreign_key "compatibility_notes", "installation_notes", column: "in_id", primary_key: "in_id", name: "compatibility_notes_ibfk_3"
  add_foreign_key "compatibility_notes", "plugins", column: "compatibility_patch", primary_key: "pl_id", name: "compatibility_notes_ibfk_2"
  add_foreign_key "compatibility_notes", "users", column: "submitted_by", primary_key: "user_id", name: "compatibility_notes_ibfk_1"
  add_foreign_key "helpful_marks", "compatibility_notes", column: "cn_id", primary_key: "cn_id", name: "helpful_marks_ibfk_2"
  add_foreign_key "helpful_marks", "installation_notes", column: "in_id", primary_key: "in_id", name: "helpful_marks_ibfk_3"
  add_foreign_key "helpful_marks", "reviews", column: "r_id", primary_key: "r_id", name: "helpful_marks_ibfk_1"
  add_foreign_key "helpful_marks", "users", column: "submitted_by", primary_key: "user_id", name: "helpful_marks_ibfk_4"
  add_foreign_key "incorrect_notes", "compatibility_notes", column: "cn_id", primary_key: "cn_id", name: "incorrect_notes_ibfk_2"
  add_foreign_key "incorrect_notes", "installation_notes", column: "in_id", primary_key: "in_id", name: "incorrect_notes_ibfk_3"
  add_foreign_key "incorrect_notes", "reviews", column: "r_id", primary_key: "r_id", name: "incorrect_notes_ibfk_1"
  add_foreign_key "incorrect_notes", "users", column: "submitted_by", primary_key: "user_id", name: "incorrect_notes_ibfk_4"
  add_foreign_key "installation_notes", "mod_versions", column: "mv_id", primary_key: "mv_id", name: "installation_notes_ibfk_2"
  add_foreign_key "installation_notes", "users", column: "submitted_by", primary_key: "user_id", name: "installation_notes_ibfk_1"
  add_foreign_key "masters", "plugins", column: "pl_id", primary_key: "pl_id", name: "masters_ibfk_1"
  add_foreign_key "mod_comments", "comments", column: "c_id", primary_key: "c_id", name: "mod_comments_ibfk_2"
  add_foreign_key "mod_comments", "mods", primary_key: "mod_id", name: "mod_comments_ibfk_1"
  add_foreign_key "mod_list_comments", "comments", column: "c_id", primary_key: "c_id", name: "mod_list_comments_ibfk_2"
  add_foreign_key "mod_list_comments", "mod_lists", column: "ml_id", primary_key: "ml_id", name: "mod_list_comments_ibfk_1"
  add_foreign_key "mod_list_compatibility_notes", "compatibility_notes", column: "cn_id", primary_key: "cn_id", name: "mod_list_compatibility_notes_ibfk_2"
  add_foreign_key "mod_list_compatibility_notes", "mod_lists", column: "ml_id", primary_key: "ml_id", name: "mod_list_compatibility_notes_ibfk_1"
  add_foreign_key "mod_list_custom_plugins", "mod_lists", column: "ml_id", primary_key: "ml_id", name: "mod_list_custom_plugins_ibfk_1"
  add_foreign_key "mod_list_installation_notes", "installation_notes", column: "in_id", primary_key: "in_id", name: "mod_list_installation_notes_ibfk_2"
  add_foreign_key "mod_list_installation_notes", "mod_lists", column: "ml_id", primary_key: "ml_id", name: "mod_list_installation_notes_ibfk_1"
  add_foreign_key "mod_list_mods", "mod_lists", column: "ml_id", primary_key: "ml_id", name: "mod_list_mods_ibfk_1"
  add_foreign_key "mod_list_mods", "mods", primary_key: "mod_id", name: "mod_list_mods_ibfk_2"
  add_foreign_key "mod_list_plugins", "mod_lists", column: "ml_id", primary_key: "ml_id", name: "mod_list_plugins_ibfk_1"
  add_foreign_key "mod_list_plugins", "plugins", column: "pl_id", primary_key: "pl_id", name: "mod_list_plugins_ibfk_2"
  add_foreign_key "mod_lists", "users", column: "created_by", primary_key: "user_id", name: "mod_lists_ibfk_1"
  add_foreign_key "mod_version_file_map", "mod_asset_files", column: "maf_id", primary_key: "maf_id", name: "mod_version_file_map_ibfk_2"
  add_foreign_key "mod_version_file_map", "mod_versions", column: "mv_id", primary_key: "mv_id", name: "mod_version_file_map_ibfk_1"
  add_foreign_key "mod_versions", "mods", primary_key: "mod_id", name: "mod_versions_ibfk_1"
  add_foreign_key "mods", "lover_infos", column: "ll_id", primary_key: "ll_id", name: "mods_ibfk_3"
  add_foreign_key "mods", "nexus_infos", column: "nm_id", primary_key: "nm_id", name: "mods_ibfk_1"
  add_foreign_key "mods", "workshop_infos", column: "ws_id", primary_key: "ws_id", name: "mods_ibfk_2"
  add_foreign_key "plugin_override_map", "masters", column: "mst_id", primary_key: "mst_id", name: "plugin_override_map_ibfk_2"
  add_foreign_key "plugin_override_map", "plugins", column: "pl_id", primary_key: "pl_id", name: "plugin_override_map_ibfk_1"
  add_foreign_key "plugin_record_groups", "plugins", column: "pl_id", primary_key: "pl_id", name: "plugin_record_groups_ibfk_1"
  add_foreign_key "plugins", "mod_versions", column: "mv_id", primary_key: "mv_id", name: "plugins_ibfk_1"
  add_foreign_key "reputation_map", "user_reputations", column: "from_rep_id", primary_key: "rep_id", name: "reputation_map_ibfk_1"
  add_foreign_key "reputation_map", "user_reputations", column: "to_rep_id", primary_key: "rep_id", name: "reputation_map_ibfk_2"
  add_foreign_key "reviews", "mods", primary_key: "mod_id", name: "reviews_ibfk_2"
  add_foreign_key "reviews", "users", column: "submitted_by", primary_key: "user_id", name: "reviews_ibfk_1"
  add_foreign_key "user_bios", "users", primary_key: "user_id", name: "user_bios_ibfk_1"
  add_foreign_key "user_comments", "comments", column: "c_id", primary_key: "c_id", name: "user_comments_ibfk_2"
  add_foreign_key "user_comments", "users", primary_key: "user_id", name: "user_comments_ibfk_1"
  add_foreign_key "user_mod_author_map", "mods", primary_key: "mod_id", name: "user_mod_author_map_ibfk_1"
  add_foreign_key "user_mod_author_map", "users", primary_key: "user_id", name: "user_mod_author_map_ibfk_2"
  add_foreign_key "user_mod_list_star_map", "mod_lists", column: "ml_id", primary_key: "ml_id", name: "user_mod_list_star_map_ibfk_1"
  add_foreign_key "user_mod_list_star_map", "users", primary_key: "user_id", name: "user_mod_list_star_map_ibfk_2"
  add_foreign_key "user_mod_star_map", "mods", primary_key: "mod_id", name: "user_mod_star_map_ibfk_1"
  add_foreign_key "user_mod_star_map", "users", primary_key: "user_id", name: "user_mod_star_map_ibfk_2"
  add_foreign_key "user_reputations", "users", primary_key: "user_id", name: "user_reputations_ibfk_1"
  add_foreign_key "user_settings", "users", primary_key: "user_id", name: "user_settings_ibfk_1"
  add_foreign_key "users", "mod_lists", column: "active_mc_id", primary_key: "ml_id", name: "users_ibfk_5"
  add_foreign_key "users", "mod_lists", column: "active_ml_id", primary_key: "ml_id", name: "users_ibfk_4"
end
