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

ActiveRecord::Schema.define(version: 20151218201600) do

  create_table "agreement_marks", force: :cascade do |t|
    t.integer  "inc_id"
    t.integer  "submitted_by"
    t.boolean  "agree"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "comments", force: :cascade do |t|
    t.integer  "c_id"
    t.integer  "parent_comment"
    t.integer  "submitted_by"
    t.boolean  "hidden"
    t.datetime "submitted"
    t.datetime "edited"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  create_table "compatibility_notes", force: :cascade do |t|
    t.integer  "cn_id"
    t.integer  "submitted_by"
    t.integer  "mod_mode"
    t.integer  "compatibility_patch"
    t.integer  "compatibility_status"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  create_table "helpful_marks", force: :cascade do |t|
    t.integer  "r_id"
    t.integer  "cn_id"
    t.integer  "in_id"
    t.integer  "submitted_by"
    t.boolean  "helpful"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "incorrect_notes", force: :cascade do |t|
    t.integer  "inc_id"
    t.integer  "r_id"
    t.integer  "cn_id"
    t.integer  "in_id"
    t.integer  "submitted_by"
    t.text     "reason"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "installation_notes", force: :cascade do |t|
    t.integer  "in_id"
    t.integer  "submitted_by"
    t.integer  "mv_id"
    t.boolean  "always"
    t.integer  "note_type"
    t.datetime "submitted"
    t.datetime "edited"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "lover_infos", force: :cascade do |t|
    t.integer  "ll_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "masters", force: :cascade do |t|
    t.integer  "mst_id"
    t.integer  "pl_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "mod_asset_files", force: :cascade do |t|
    t.integer  "maf_id"
    t.string   "filepath"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "mod_comments", force: :cascade do |t|
    t.integer  "mod_id"
    t.integer  "c_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "mod_list_comments", force: :cascade do |t|
    t.integer  "ml_id"
    t.integer  "c_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "mod_list_compatibility_notes", force: :cascade do |t|
    t.integer  "ml_id"
    t.integer  "cn_id"
    t.integer  "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "mod_list_custom_plugins", force: :cascade do |t|
    t.integer  "ml_id"
    t.boolean  "active"
    t.integer  "load_order"
    t.string   "title"
    t.text     "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "mod_list_installation_notes", force: :cascade do |t|
    t.integer  "ml_id"
    t.integer  "in_id"
    t.integer  "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "mod_list_mods", force: :cascade do |t|
    t.integer  "ml_id"
    t.integer  "mod_id"
    t.boolean  "active"
    t.integer  "install_order"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "mod_list_plugins", force: :cascade do |t|
    t.integer  "ml_id"
    t.integer  "pl_id"
    t.boolean  "active"
    t.integer  "load_order"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "mod_lists", force: :cascade do |t|
    t.integer  "ml_id"
    t.text     "game"
    t.integer  "created_by"
    t.boolean  "is_collection"
    t.boolean  "is_public"
    t.boolean  "has_adult_content"
    t.integer  "status"
    t.datetime "created"
    t.datetime "completed"
    t.text     "description"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  create_table "mod_version_file_maps", force: :cascade do |t|
    t.integer  "mv_id"
    t.integer  "maf_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "mod_versions", force: :cascade do |t|
    t.integer  "mv_id"
    t.integer  "mod_id"
    t.datetime "released"
    t.boolean  "obsolete"
    t.boolean  "dangerous"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "mods", force: :cascade do |t|
    t.integer  "mod_id"
    t.text     "game"
    t.text     "name"
    t.text     "aliases"
    t.boolean  "is_utility"
    t.integer  "category"
    t.boolean  "has_adult_content"
    t.integer  "nm_id"
    t.integer  "ws_id"
    t.integer  "ll_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  create_table "nexus_infos", force: :cascade do |t|
    t.integer  "nm_id"
    t.text     "uploaded_by"
    t.text     "authors"
    t.integer  "endorsements"
    t.integer  "total_downloads"
    t.integer  "unique_downloads"
    t.integer  "views"
    t.integer  "posts_count"
    t.integer  "videos_count"
    t.integer  "images_count"
    t.integer  "files_count"
    t.integer  "articles_count"
    t.integer  "nexus_category"
    t.text     "changelog"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  create_table "plugin_override_maps", force: :cascade do |t|
    t.integer  "pl_id"
    t.integer  "mst_id"
    t.integer  "form_id"
    t.string   "sig"
    t.text     "name"
    t.boolean  "is_itm"
    t.boolean  "is_itpo"
    t.boolean  "is_udr"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "plugin_record_groups", force: :cascade do |t|
    t.integer  "pl_id"
    t.string   "sig"
    t.text     "name"
    t.integer  "new_records"
    t.integer  "override_records"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  create_table "plugins", force: :cascade do |t|
    t.integer  "pl_id"
    t.integer  "mv_id"
    t.text     "filename"
    t.text     "author"
    t.text     "description"
    t.string   "hash"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "reputation_maps", force: :cascade do |t|
    t.integer  "from_rep_id"
    t.integer  "to_rep_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "reviews", force: :cascade do |t|
    t.integer  "r_id"
    t.integer  "submitted_by"
    t.integer  "mod_id"
    t.boolean  "hidden"
    t.string   "rating1"
    t.string   "TINYINT"
    t.string   "rating2"
    t.string   "rating3"
    t.string   "rating4"
    t.string   "rating5"
    t.datetime "submitted"
    t.datetime "edited"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "user_bios", force: :cascade do |t|
    t.integer  "bio_id"
    t.string   "nexus_username"
    t.boolean  "nexus_verified"
    t.string   "lover_username"
    t.boolean  "lover_verified"
    t.string   "steam_username"
    t.boolean  "steam_verified"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  create_table "user_comments", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "c_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_mod_author_maps", force: :cascade do |t|
    t.integer  "mod_id"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_mod_list_star_maps", force: :cascade do |t|
    t.integer  "ml_id"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_mod_star_maps", force: :cascade do |t|
    t.integer  "mod_id"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_reputations", force: :cascade do |t|
    t.integer  "rep_id"
    t.float    "overall"
    t.float    "offset"
    t.float    "audiovisual_design"
    t.float    "plugin_design"
    t.float    "utilty_design"
    t.float    "script_design"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  create_table "user_settings", force: :cascade do |t|
    t.integer  "set_id"
    t.boolean  "show_notifications"
    t.boolean  "show_tooltips"
    t.boolean  "email_notifications"
    t.boolean  "email_public"
    t.boolean  "allow_adult_content"
    t.boolean  "allow_nexus_mods"
    t.boolean  "allow_lovers_lab"
    t.boolean  "allow_steam_workshop"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  create_table "users", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "username"
    t.string   "email"
    t.string   "hash"
    t.integer  "user_level"
    t.string   "title"
    t.text     "avatar"
    t.datetime "joined"
    t.datetime "last_seen"
    t.integer  "bio_id"
    t.integer  "set_id"
    t.integer  "rep_id"
    t.integer  "active_ml_id"
    t.integer  "active_mc_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "workshop_infos", force: :cascade do |t|
    t.integer  "ws_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
