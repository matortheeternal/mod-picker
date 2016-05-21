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

ActiveRecord::Schema.define(version: 20160521003451) do

  create_table "agreement_marks", id: false, force: :cascade do |t|
    t.integer "incorrect_note_id", limit: 4
    t.integer "submitted_by",      limit: 4
    t.boolean "agree"
  end

  add_index "agreement_marks", ["incorrect_note_id"], name: "inc_id", using: :btree
  add_index "agreement_marks", ["submitted_by"], name: "submitted_by", using: :btree

  create_table "articles", force: :cascade do |t|
    t.string   "title",          limit: 255,               null: false
    t.integer  "submitted_by",   limit: 4,                 null: false
    t.text     "text_body",      limit: 65535,             null: false
    t.datetime "submitted",                                null: false
    t.datetime "edited",                                   null: false
    t.integer  "game_id",        limit: 4
    t.integer  "comments_count", limit: 4,     default: 0
  end

  add_index "articles", ["submitted_by"], name: "fk_rails_ea02c233bd", using: :btree

  create_table "asset_files", force: :cascade do |t|
    t.string  "filepath",              limit: 255,             null: false
    t.integer "game_id",               limit: 4,               null: false
    t.integer "mod_asset_files_count", limit: 4,   default: 0
  end

  add_index "asset_files", ["filepath"], name: "filepath", unique: true, using: :btree
  add_index "asset_files", ["game_id"], name: "fk_rails_2e8fb86f89", using: :btree

  create_table "base_reports", force: :cascade do |t|
    t.integer  "reportable_id",   limit: 4,               null: false
    t.string   "reportable_type", limit: 255,             null: false
    t.datetime "submitted",                               null: false
    t.datetime "edited",                                  null: false
    t.integer  "reports_count",   limit: 4,   default: 0
  end

  create_table "categories", force: :cascade do |t|
    t.integer "parent_id",   limit: 4
    t.string  "name",        limit: 64
    t.string  "description", limit: 255
  end

  add_index "categories", ["parent_id"], name: "fk_rails_82f48f7407", using: :btree

  create_table "category_priorities", id: false, force: :cascade do |t|
    t.integer "dominant_id",  limit: 4
    t.integer "recessive_id", limit: 4
    t.string  "description",  limit: 255
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
    t.integer "children_count",   limit: 4,     default: 0
  end

  add_index "comments", ["commentable_type", "commentable_id"], name: "index_comments_on_commentable_type_and_commentable_id", using: :btree
  add_index "comments", ["parent_comment"], name: "parent_comment", using: :btree
  add_index "comments", ["submitted_by"], name: "submitted_by", using: :btree

  create_table "compatibility_note_history_entries", force: :cascade do |t|
    t.integer  "compatibility_note_id",   limit: 4,                 null: false
    t.string   "edit_summary",            limit: 255,               null: false
    t.integer  "submitted_by",            limit: 4,                 null: false
    t.integer  "compatibility_mod_id",    limit: 4
    t.integer  "compatibility_plugin_id", limit: 4
    t.integer  "compatibility_type",      limit: 1,     default: 0, null: false
    t.datetime "submitted"
    t.datetime "edited"
    t.text     "text_body",               limit: 65535
  end

  add_index "compatibility_note_history_entries", ["compatibility_mod_id"], name: "fk_rails_e1c933535e", using: :btree
  add_index "compatibility_note_history_entries", ["compatibility_note_id"], name: "fk_rails_4970df5c77", using: :btree
  add_index "compatibility_note_history_entries", ["compatibility_plugin_id"], name: "fk_rails_6466cbf704", using: :btree
  add_index "compatibility_note_history_entries", ["submitted_by"], name: "fk_rails_7e4343a2d1", using: :btree

  create_table "compatibility_notes", force: :cascade do |t|
    t.integer  "submitted_by",            limit: 4
    t.integer  "compatibility_plugin_id", limit: 4
    t.integer  "compatibility_type",      limit: 1,     default: 0,     null: false
    t.datetime "submitted"
    t.datetime "edited"
    t.text     "text_body",               limit: 65535
    t.integer  "incorrect_notes_count",   limit: 4,     default: 0
    t.integer  "compatibility_mod_id",    limit: 4
    t.boolean  "hidden",                                default: false, null: false
    t.integer  "first_mod_id",            limit: 4
    t.integer  "second_mod_id",           limit: 4
    t.integer  "game_id",                 limit: 4,                     null: false
    t.boolean  "approved",                              default: false
    t.string   "moderator_message",       limit: 255
    t.integer  "helpful_count",           limit: 4,     default: 0
    t.integer  "not_helpful_count",       limit: 4,     default: 0
    t.integer  "history_entries_count",   limit: 4,     default: 0
  end

  add_index "compatibility_notes", ["compatibility_plugin_id"], name: "compatibility_patch", using: :btree
  add_index "compatibility_notes", ["first_mod_id"], name: "fk_rails_3524228f07", using: :btree
  add_index "compatibility_notes", ["game_id"], name: "fk_rails_c18131e78a", using: :btree
  add_index "compatibility_notes", ["second_mod_id"], name: "fk_rails_10dd0a50f6", using: :btree
  add_index "compatibility_notes", ["submitted_by"], name: "submitted_by", using: :btree

  create_table "config_files", force: :cascade do |t|
    t.integer "game_id",           limit: 4,                 null: false
    t.string  "filename",          limit: 64,                null: false
    t.string  "install_path",      limit: 128,               null: false
    t.text    "default_text_body", limit: 65535
    t.integer "mod_lists_count",   limit: 4,     default: 0
  end

  add_index "config_files", ["game_id", "filename"], name: "index_config_files_on_game_id_and_filename", using: :btree

  create_table "dummy_masters", id: false, force: :cascade do |t|
    t.integer "plugin_id", limit: 4
    t.string  "filename",  limit: 64
    t.integer "index",     limit: 4
  end

  add_index "dummy_masters", ["plugin_id"], name: "fk_rails_2552b596d8", using: :btree

  create_table "games", force: :cascade do |t|
    t.string  "display_name",              limit: 32
    t.string  "long_name",                 limit: 128
    t.string  "abbr_name",                 limit: 32
    t.string  "exe_name",                  limit: 32
    t.string  "steam_app_ids",             limit: 64
    t.string  "nexus_name",                limit: 16
    t.integer "asset_files_count",         limit: 4,   default: 0
    t.integer "mods_count",                limit: 4,   default: 0
    t.integer "nexus_infos_count",         limit: 4,   default: 0
    t.integer "lover_infos_count",         limit: 4,   default: 0
    t.integer "workshop_infos_count",      limit: 4,   default: 0
    t.integer "mod_lists_count",           limit: 4,   default: 0
    t.integer "config_files_count",        limit: 4,   default: 0
    t.integer "compatibility_notes_count", limit: 4,   default: 0
    t.integer "install_order_notes_count", limit: 4,   default: 0
    t.integer "load_order_notes_count",    limit: 4,   default: 0
    t.integer "reviews_count",             limit: 4,   default: 0
    t.integer "plugins_count",             limit: 4,   default: 0
  end

  create_table "help_pages", force: :cascade do |t|
    t.string   "name",           limit: 128,               null: false
    t.datetime "submitted"
    t.datetime "edited"
    t.text     "text_body",      limit: 65535
    t.integer  "comments_count", limit: 4,     default: 0
  end

  create_table "helpful_marks", id: false, force: :cascade do |t|
    t.integer  "submitted_by",     limit: 4
    t.boolean  "helpful"
    t.integer  "helpfulable_id",   limit: 4
    t.string   "helpfulable_type", limit: 255
    t.datetime "submitted"
  end

  add_index "helpful_marks", ["helpfulable_type", "helpfulable_id"], name: "index_helpful_marks_on_helpfulable_type_and_helpfulable_id", using: :btree
  add_index "helpful_marks", ["submitted_by"], name: "submitted_by", using: :btree

  create_table "incorrect_notes", force: :cascade do |t|
    t.integer  "submitted_by",     limit: 4
    t.text     "text_body",        limit: 65535
    t.integer  "correctable_id",   limit: 4
    t.string   "correctable_type", limit: 255
    t.datetime "submitted"
    t.datetime "edited"
    t.boolean  "hidden",                         default: false, null: false
    t.integer  "game_id",          limit: 4,                     null: false
    t.integer  "comments_count",   limit: 4,     default: 0
    t.integer  "agree_count",      limit: 4,     default: 0
    t.integer  "disagree_count",   limit: 4,     default: 0
  end

  add_index "incorrect_notes", ["correctable_type", "correctable_id"], name: "index_incorrect_notes_on_correctable_type_and_correctable_id", using: :btree
  add_index "incorrect_notes", ["game_id"], name: "fk_rails_6d40e5f2cc", using: :btree
  add_index "incorrect_notes", ["submitted_by"], name: "submitted_by", using: :btree

  create_table "install_order_note_history_entries", force: :cascade do |t|
    t.integer  "install_order_note_id", limit: 4,     null: false
    t.string   "edit_summary",          limit: 255,   null: false
    t.integer  "submitted_by",          limit: 4,     null: false
    t.datetime "submitted"
    t.datetime "edited"
    t.text     "text_body",             limit: 65535
  end

  add_index "install_order_note_history_entries", ["install_order_note_id"], name: "fk_rails_f5643ed650", using: :btree
  add_index "install_order_note_history_entries", ["submitted_by"], name: "fk_rails_18a032d0ac", using: :btree

  create_table "install_order_notes", force: :cascade do |t|
    t.integer  "submitted_by",          limit: 4,                     null: false
    t.integer  "first_mod_id",          limit: 4,                     null: false
    t.integer  "second_mod_id",         limit: 4,                     null: false
    t.datetime "submitted"
    t.datetime "edited"
    t.text     "text_body",             limit: 65535
    t.boolean  "hidden",                              default: false, null: false
    t.integer  "game_id",               limit: 4,                     null: false
    t.boolean  "approved",                            default: false
    t.string   "moderator_message",     limit: 255
    t.integer  "helpful_count",         limit: 4,     default: 0
    t.integer  "not_helpful_count",     limit: 4,     default: 0
    t.integer  "history_entries_count", limit: 4,     default: 0
    t.integer  "comments_count",        limit: 4,     default: 0
    t.integer  "incorrect_notes_count", limit: 4,     default: 0
  end

  add_index "install_order_notes", ["first_mod_id"], name: "fk_rails_bc30c8f58f", using: :btree
  add_index "install_order_notes", ["game_id"], name: "fk_rails_aa90c33b77", using: :btree
  add_index "install_order_notes", ["second_mod_id"], name: "fk_rails_b74bbcab8b", using: :btree
  add_index "install_order_notes", ["submitted_by"], name: "fk_rails_ea0bdedfde", using: :btree

  create_table "load_order_note_history_entries", force: :cascade do |t|
    t.integer  "load_order_note_id", limit: 4,     null: false
    t.string   "edit_summary",       limit: 255,   null: false
    t.integer  "submitted_by",       limit: 4,     null: false
    t.datetime "submitted"
    t.datetime "edited"
    t.text     "text_body",          limit: 65535
  end

  add_index "load_order_note_history_entries", ["load_order_note_id"], name: "fk_rails_f99a4f8204", using: :btree
  add_index "load_order_note_history_entries", ["submitted_by"], name: "fk_rails_478afef4a8", using: :btree

  create_table "load_order_notes", force: :cascade do |t|
    t.integer  "submitted_by",      limit: 4,                     null: false
    t.integer  "first_plugin_id",   limit: 4,                     null: false
    t.integer  "second_plugin_id",  limit: 4,                     null: false
    t.datetime "submitted"
    t.datetime "edited"
    t.text     "text_body",         limit: 65535
    t.boolean  "hidden",                          default: false, null: false
    t.integer  "game_id",           limit: 4,                     null: false
    t.boolean  "approved",                        default: false
    t.string   "moderator_message", limit: 255
    t.integer  "helpful_count",     limit: 4,     default: 0
    t.integer  "not_helpful_count", limit: 4,     default: 0
  end

  add_index "load_order_notes", ["first_plugin_id"], name: "fk_rails_d6c931c1cc", using: :btree
  add_index "load_order_notes", ["game_id"], name: "fk_rails_cd2fa42211", using: :btree
  add_index "load_order_notes", ["second_plugin_id"], name: "fk_rails_af9e3c9509", using: :btree
  add_index "load_order_notes", ["submitted_by"], name: "fk_rails_9992d700a9", using: :btree

  create_table "lover_infos", force: :cascade do |t|
    t.integer  "mod_id",            limit: 4
    t.string   "mod_name",          limit: 255
    t.string   "uploaded_by",       limit: 128
    t.string   "date_submitted",    limit: 255
    t.string   "date_updated",      limit: 255
    t.datetime "last_scraped"
    t.integer  "followers_count",   limit: 4,   default: 0
    t.integer  "file_size",         limit: 4,   default: 0
    t.integer  "views",             limit: 4,   default: 0
    t.integer  "downloads",         limit: 4,   default: 0
    t.boolean  "has_stats",                     default: false
    t.string   "current_version",   limit: 32
    t.boolean  "has_adult_content"
    t.integer  "game_id",           limit: 4
  end

  add_index "lover_infos", ["game_id"], name: "fk_rails_0c0c747a5a", using: :btree
  add_index "lover_infos", ["mod_id"], name: "fk_rails_614a886dc0", using: :btree

  create_table "masters", id: false, force: :cascade do |t|
    t.integer "plugin_id",        limit: 4
    t.integer "master_plugin_id", limit: 4
    t.integer "index",            limit: 4
  end

  add_index "masters", ["plugin_id"], name: "pl_id", using: :btree

  create_table "mod_asset_files", id: false, force: :cascade do |t|
    t.integer "mod_id",        limit: 4
    t.integer "asset_file_id", limit: 4
  end

  add_index "mod_asset_files", ["asset_file_id"], name: "maf_id", using: :btree
  add_index "mod_asset_files", ["mod_id"], name: "mv_id", using: :btree

  create_table "mod_authors", id: false, force: :cascade do |t|
    t.integer "mod_id",  limit: 4
    t.integer "user_id", limit: 4
  end

  add_index "mod_authors", ["mod_id"], name: "mod_id", using: :btree
  add_index "mod_authors", ["user_id"], name: "user_id", using: :btree

  create_table "mod_list_compatibility_notes", id: false, force: :cascade do |t|
    t.integer "mod_list_id",           limit: 4
    t.integer "compatibility_note_id", limit: 4
    t.integer "status",                limit: 1, default: 0, null: false
  end

  add_index "mod_list_compatibility_notes", ["compatibility_note_id"], name: "cn_id", using: :btree
  add_index "mod_list_compatibility_notes", ["mod_list_id"], name: "ml_id", using: :btree

  create_table "mod_list_config_files", id: false, force: :cascade do |t|
    t.integer "mod_list_id",    limit: 4,     null: false
    t.integer "config_file_id", limit: 4,     null: false
    t.text    "text_body",      limit: 65535
  end

  add_index "mod_list_config_files", ["config_file_id"], name: "fk_rails_fd08eb71ee", using: :btree
  add_index "mod_list_config_files", ["mod_list_id"], name: "fk_rails_e706555c10", using: :btree

  create_table "mod_list_custom_config_files", force: :cascade do |t|
    t.integer "mod_list_id",  limit: 4,     null: false
    t.string  "filename",     limit: 64,    null: false
    t.string  "install_path", limit: 128,   null: false
    t.text    "text_body",    limit: 65535
  end

  add_index "mod_list_custom_config_files", ["mod_list_id"], name: "fk_rails_af192d0984", using: :btree

  create_table "mod_list_custom_plugins", force: :cascade do |t|
    t.integer "mod_list_id", limit: 4
    t.boolean "active"
    t.integer "index",       limit: 2
    t.string  "filename",    limit: 64
    t.text    "description", limit: 65535
  end

  add_index "mod_list_custom_plugins", ["mod_list_id"], name: "ml_id", using: :btree

  create_table "mod_list_install_order_notes", id: false, force: :cascade do |t|
    t.integer "mod_list_id",           limit: 4
    t.integer "install_order_note_id", limit: 4
    t.integer "status",                limit: 1, default: 0, null: false
  end

  add_index "mod_list_install_order_notes", ["install_order_note_id"], name: "in_id", using: :btree
  add_index "mod_list_install_order_notes", ["mod_list_id"], name: "ml_id", using: :btree

  create_table "mod_list_load_order_notes", id: false, force: :cascade do |t|
    t.integer "mod_list_id",        limit: 4,             null: false
    t.integer "load_order_note_id", limit: 4,             null: false
    t.integer "status",             limit: 1, default: 0, null: false
  end

  add_index "mod_list_load_order_notes", ["load_order_note_id"], name: "index_mod_list_load_order_notes_on_load_order_note_id", using: :btree
  add_index "mod_list_load_order_notes", ["mod_list_id"], name: "index_mod_list_load_order_notes_on_mod_list_id", using: :btree

  create_table "mod_list_mods", id: false, force: :cascade do |t|
    t.integer "mod_list_id", limit: 4
    t.integer "mod_id",      limit: 4
    t.boolean "active"
    t.integer "index",       limit: 4
  end

  add_index "mod_list_mods", ["mod_id"], name: "mod_id", using: :btree
  add_index "mod_list_mods", ["mod_list_id"], name: "ml_id", using: :btree

  create_table "mod_list_plugins", id: false, force: :cascade do |t|
    t.integer "mod_list_id", limit: 4
    t.integer "plugin_id",   limit: 4
    t.boolean "active"
    t.integer "index",       limit: 4
  end

  add_index "mod_list_plugins", ["mod_list_id"], name: "ml_id", using: :btree
  add_index "mod_list_plugins", ["plugin_id"], name: "pl_id", using: :btree

  create_table "mod_list_stars", id: false, force: :cascade do |t|
    t.integer "mod_list_id", limit: 4
    t.integer "user_id",     limit: 4
  end

  add_index "mod_list_stars", ["mod_list_id"], name: "ml_id", using: :btree
  add_index "mod_list_stars", ["user_id"], name: "user_id", using: :btree

  create_table "mod_list_tags", force: :cascade do |t|
    t.integer "tag_id",       limit: 4, null: false
    t.integer "mod_list_id",  limit: 4, null: false
    t.integer "submitted_by", limit: 4, null: false
  end

  add_index "mod_list_tags", ["mod_list_id"], name: "fk_rails_7de991735e", using: :btree
  add_index "mod_list_tags", ["submitted_by"], name: "fk_rails_4ab6737116", using: :btree
  add_index "mod_list_tags", ["tag_id"], name: "fk_rails_1632b7f954", using: :btree

  create_table "mod_lists", force: :cascade do |t|
    t.integer  "created_by",                limit: 4
    t.boolean  "is_collection"
    t.boolean  "hidden",                                  default: true, null: false
    t.boolean  "has_adult_content"
    t.integer  "status",                    limit: 1,     default: 0,    null: false
    t.datetime "submitted"
    t.datetime "edited"
    t.text     "description",               limit: 65535
    t.integer  "game_id",                   limit: 4
    t.integer  "comments_count",            limit: 4,     default: 0
    t.integer  "mods_count",                limit: 4,     default: 0
    t.integer  "plugins_count",             limit: 4,     default: 0
    t.integer  "custom_plugins_count",      limit: 4,     default: 0
    t.integer  "compatibility_notes_count", limit: 4,     default: 0
    t.integer  "install_order_notes_count", limit: 4,     default: 0
    t.integer  "stars_count",               limit: 4,     default: 0
    t.integer  "load_order_notes_count",    limit: 4,     default: 0
    t.string   "name",                      limit: 255
    t.integer  "active_plugins_count",      limit: 4,     default: 0
    t.integer  "tags_count",                limit: 4,     default: 0
    t.integer  "config_files_count",        limit: 4,     default: 0
    t.integer  "custom_config_files_count", limit: 4,     default: 0
  end

  add_index "mod_lists", ["created_by"], name: "created_by", using: :btree
  add_index "mod_lists", ["game_id"], name: "fk_rails_f25cbc0432", using: :btree

  create_table "mod_requirements", id: false, force: :cascade do |t|
    t.integer "mod_id",      limit: 4, null: false
    t.integer "required_id", limit: 4, null: false
  end

  add_index "mod_requirements", ["mod_id"], name: "fk_rails_5a311577a9", using: :btree
  add_index "mod_requirements", ["required_id"], name: "fk_rails_05046fa6e5", using: :btree

  create_table "mod_stars", id: false, force: :cascade do |t|
    t.integer "mod_id",  limit: 4
    t.integer "user_id", limit: 4
  end

  add_index "mod_stars", ["mod_id"], name: "mod_id", using: :btree
  add_index "mod_stars", ["user_id"], name: "user_id", using: :btree

  create_table "mod_tags", id: false, force: :cascade do |t|
    t.integer "mod_id",       limit: 4, null: false
    t.integer "tag_id",       limit: 4, null: false
    t.integer "submitted_by", limit: 4
  end

  add_index "mod_tags", ["mod_id"], name: "fk_rails_5ab248dd85", using: :btree
  add_index "mod_tags", ["submitted_by"], name: "fk_rails_ad8ec1982c", using: :btree
  add_index "mod_tags", ["tag_id"], name: "fk_rails_ffd7f5019d", using: :btree

  create_table "mods", force: :cascade do |t|
    t.string   "name",                      limit: 128
    t.string   "aliases",                   limit: 128
    t.boolean  "is_utility"
    t.boolean  "has_adult_content"
    t.integer  "game_id",                   limit: 4
    t.integer  "primary_category_id",       limit: 4
    t.integer  "secondary_category_id",     limit: 4
    t.integer  "stars_count",               limit: 4,   default: 0
    t.integer  "reviews_count",             limit: 4,   default: 0
    t.integer  "compatibility_notes_count", limit: 4,   default: 0
    t.integer  "install_order_notes_count", limit: 4,   default: 0
    t.integer  "load_order_notes_count",    limit: 4,   default: 0
    t.integer  "status",                    limit: 1,   default: 0,     null: false
    t.boolean  "hidden",                                default: false, null: false
    t.integer  "submitted_by",              limit: 4,                   null: false
    t.float    "reputation",                limit: 24,  default: 0.0
    t.float    "average_rating",            limit: 24,  default: 0.0
    t.datetime "released"
    t.datetime "updated"
    t.integer  "plugins_count",             limit: 4,   default: 0
    t.integer  "required_mods_count",       limit: 4,   default: 0
    t.integer  "mod_lists_count",           limit: 4,   default: 0
    t.integer  "asset_files_count",         limit: 4,   default: 0
    t.integer  "required_by_count",         limit: 4,   default: 0
    t.integer  "tags_count",                limit: 4,   default: 0
  end

  add_index "mods", ["game_id"], name: "fk_rails_3ec448a848", using: :btree
  add_index "mods", ["primary_category_id"], name: "fk_rails_42759f5da5", using: :btree
  add_index "mods", ["secondary_category_id"], name: "fk_rails_26f394ea9d", using: :btree
  add_index "mods", ["submitted_by"], name: "fk_rails_5f28cca69a", using: :btree

  create_table "nexus_infos", force: :cascade do |t|
    t.string   "uploaded_by",         limit: 128
    t.string   "authors",             limit: 128
    t.datetime "date_added"
    t.datetime "date_updated"
    t.integer  "endorsements",        limit: 4,   default: 0
    t.integer  "total_downloads",     limit: 4,   default: 0
    t.integer  "unique_downloads",    limit: 4,   default: 0
    t.integer  "views",               limit: 4,   default: 0
    t.integer  "posts_count",         limit: 4,   default: 0
    t.integer  "videos_count",        limit: 4,   default: 0
    t.integer  "images_count",        limit: 4,   default: 0
    t.integer  "files_count",         limit: 4,   default: 0
    t.integer  "articles_count",      limit: 4,   default: 0
    t.integer  "nexus_category",      limit: 2
    t.integer  "mod_id",              limit: 4
    t.integer  "game_id",             limit: 4
    t.string   "mod_name",            limit: 255
    t.string   "current_version",     limit: 255
    t.datetime "last_scraped"
    t.float    "endorsement_rate",    limit: 24,  default: 0.0
    t.float    "dl_rate",             limit: 24,  default: 0.0
    t.float    "udl_to_endorsements", limit: 24,  default: 0.0
    t.float    "udl_to_posts",        limit: 24,  default: 0.0
    t.float    "tdl_to_udl",          limit: 24,  default: 0.0
    t.float    "views_to_tdl",        limit: 24,  default: 0.0
    t.boolean  "has_stats",                       default: false
  end

  add_index "nexus_infos", ["game_id"], name: "fk_rails_46e3032463", using: :btree

  create_table "override_records", id: false, force: :cascade do |t|
    t.integer "plugin_id", limit: 4
    t.integer "fid",       limit: 4
    t.string  "sig",       limit: 4
  end

  add_index "override_records", ["plugin_id"], name: "pl_id", using: :btree

  create_table "plugin_errors", force: :cascade do |t|
    t.integer "plugin_id", limit: 4,   null: false
    t.string  "signature", limit: 4,   null: false
    t.integer "form_id",   limit: 4,   null: false
    t.integer "group",     limit: 1,   null: false
    t.string  "path",      limit: 400
    t.string  "name",      limit: 400
    t.string  "data",      limit: 255
  end

  add_index "plugin_errors", ["plugin_id"], name: "fk_rails_21e72cc4b6", using: :btree

  create_table "plugin_record_groups", id: false, force: :cascade do |t|
    t.integer "plugin_id",      limit: 4
    t.string  "sig",            limit: 4
    t.integer "record_count",   limit: 4
    t.integer "override_count", limit: 4
  end

  add_index "plugin_record_groups", ["plugin_id"], name: "pl_id", using: :btree

  create_table "plugins", force: :cascade do |t|
    t.integer "mod_id",         limit: 4
    t.string  "filename",       limit: 64
    t.string  "author",         limit: 128
    t.string  "description",    limit: 512
    t.string  "crc_hash",       limit: 8
    t.integer "record_count",   limit: 4
    t.integer "override_count", limit: 4
    t.integer "file_size",      limit: 4
    t.integer "game_id",        limit: 4,   null: false
  end

  add_index "plugins", ["game_id"], name: "fk_rails_5a7ba47709", using: :btree
  add_index "plugins", ["mod_id"], name: "mv_id", using: :btree

  create_table "quotes", force: :cascade do |t|
    t.integer "game_id", limit: 4,   null: false
    t.string  "text",    limit: 255, null: false
    t.string  "label",   limit: 32,  null: false
  end

  add_index "quotes", ["game_id"], name: "fk_rails_273247f4b3", using: :btree

  create_table "record_groups", force: :cascade do |t|
    t.integer "game_id",     limit: 4
    t.string  "signature",   limit: 4
    t.string  "name",        limit: 64
    t.boolean "child_group"
  end

  add_index "record_groups", ["game_id", "signature"], name: "index_record_groups_on_game_id_and_signature", unique: true, using: :btree

  create_table "reports", force: :cascade do |t|
    t.integer  "base_report_id", limit: 4,   null: false
    t.integer  "submitted_by",   limit: 4,   null: false
    t.integer  "type",           limit: 1,   null: false
    t.string   "note",           limit: 128
    t.datetime "submitted",                  null: false
    t.datetime "edited",                     null: false
  end

  add_index "reports", ["base_report_id"], name: "fk_rails_619eb511d7", using: :btree
  add_index "reports", ["submitted_by"], name: "fk_rails_41fbf0e712", using: :btree

  create_table "reputation_links", id: false, force: :cascade do |t|
    t.integer "from_rep_id", limit: 4
    t.integer "to_rep_id",   limit: 4
  end

  add_index "reputation_links", ["from_rep_id"], name: "from_rep_id", using: :btree
  add_index "reputation_links", ["to_rep_id"], name: "to_rep_id", using: :btree

  create_table "review_ratings", id: false, force: :cascade do |t|
    t.integer "review_id",         limit: 4
    t.integer "review_section_id", limit: 4
    t.integer "rating",            limit: 1
  end

  add_index "review_ratings", ["review_id"], name: "fk_rails_9b82eee8c2", using: :btree
  add_index "review_ratings", ["review_section_id"], name: "fk_rails_60e75c535e", using: :btree

  create_table "review_sections", force: :cascade do |t|
    t.integer "category_id", limit: 4
    t.string  "name",        limit: 32,                  null: false
    t.string  "prompt",      limit: 255,                 null: false
    t.boolean "default",                 default: false
  end

  add_index "review_sections", ["category_id"], name: "fk_rails_82a032f049", using: :btree

  create_table "reviews", force: :cascade do |t|
    t.integer  "submitted_by",          limit: 4
    t.integer  "mod_id",                limit: 4
    t.boolean  "hidden"
    t.datetime "submitted"
    t.datetime "edited"
    t.text     "text_body",             limit: 65535
    t.integer  "incorrect_notes_count", limit: 4,     default: 0
    t.integer  "game_id",               limit: 4,                     null: false
    t.boolean  "approved",                            default: false
    t.string   "moderator_message",     limit: 255
    t.integer  "helpful_count",         limit: 4,     default: 0
    t.integer  "not_helpful_count",     limit: 4,     default: 0
    t.integer  "ratings_count",         limit: 4,     default: 0
  end

  add_index "reviews", ["game_id"], name: "fk_rails_dfb9dc48b4", using: :btree
  add_index "reviews", ["mod_id"], name: "mod_id", using: :btree
  add_index "reviews", ["submitted_by"], name: "submitted_by", using: :btree

  create_table "tags", force: :cascade do |t|
    t.string  "text",            limit: 255,                 null: false
    t.integer "game_id",         limit: 4,                   null: false
    t.integer "submitted_by",    limit: 4,                   null: false
    t.integer "mods_count",      limit: 4,   default: 0
    t.integer "mod_lists_count", limit: 4,   default: 0
    t.boolean "hidden",                      default: false, null: false
  end

  add_index "tags", ["game_id"], name: "fk_rails_21222987c6", using: :btree
  add_index "tags", ["submitted_by"], name: "fk_rails_8c7521065c", using: :btree

  create_table "user_bios", force: :cascade do |t|
    t.integer "user_id",                     limit: 4
    t.string  "nexus_user_path",             limit: 64
    t.string  "nexus_verification_token",    limit: 32
    t.string  "nexus_username",              limit: 32
    t.date    "nexus_date_joined"
    t.integer "nexus_posts_count",           limit: 4,  default: 0
    t.string  "lover_user_path",             limit: 64
    t.string  "lover_verification_token",    limit: 32
    t.string  "lover_username",              limit: 32
    t.date    "lover_date_joined"
    t.integer "lover_posts_count",           limit: 4,  default: 0
    t.string  "workshop_user_path",          limit: 64
    t.string  "workshop_username",           limit: 32
    t.integer "workshop_submissions_count",  limit: 4,  default: 0
    t.integer "workshop_followers_count",    limit: 4,  default: 0
    t.string  "workshop_verification_token", limit: 32
  end

  add_index "user_bios", ["user_id"], name: "user_id", using: :btree

  create_table "user_reputations", force: :cascade do |t|
    t.float    "overall",          limit: 24
    t.float    "offset",           limit: 24
    t.integer  "user_id",          limit: 4
    t.float    "site_rep",         limit: 24
    t.float    "contribution_rep", limit: 24
    t.float    "author_rep",       limit: 24
    t.float    "given_rep",        limit: 24
    t.datetime "last_computed"
    t.boolean  "dont_compute"
    t.integer  "rep_from_count",   limit: 4,  default: 0
    t.integer  "rep_to_count",     limit: 4,  default: 0
  end

  add_index "user_reputations", ["user_id"], name: "user_id", using: :btree

  create_table "user_settings", force: :cascade do |t|
    t.boolean "show_notifications",               default: true
    t.boolean "show_tooltips",                    default: true
    t.boolean "email_notifications",              default: false
    t.boolean "email_public",                     default: false
    t.boolean "allow_adult_content",              default: false
    t.boolean "allow_nexus_mods",                 default: true
    t.boolean "allow_lovers_lab",                 default: false
    t.boolean "allow_steam_workshop",             default: true
    t.integer "user_id",              limit: 4
    t.string  "timezone",             limit: 128
    t.string  "udate_format",         limit: 128
    t.string  "utime_format",         limit: 128
    t.boolean "allow_comments"
    t.string  "theme",                limit: 255
  end

  add_index "user_settings", ["user_id"], name: "user_id", using: :btree

  create_table "user_titles", force: :cascade do |t|
    t.integer "game_id",      limit: 4
    t.string  "title",        limit: 32
    t.integer "rep_required", limit: 4
  end

  add_index "user_titles", ["game_id"], name: "fk_rails_4a6dc16a81", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "username",                  limit: 32
    t.string   "role",                      limit: 16
    t.string   "title",                     limit: 32
    t.datetime "joined"
    t.integer  "active_mod_list_id",        limit: 4
    t.string   "email",                     limit: 255,   default: "", null: false
    t.string   "encrypted_password",        limit: 255,   default: "", null: false
    t.string   "reset_password_token",      limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",             limit: 4,     default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",        limit: 255
    t.string   "last_sign_in_ip",           limit: 255
    t.string   "confirmation_token",        limit: 255
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.integer  "comments_count",            limit: 4,     default: 0
    t.integer  "reviews_count",             limit: 4,     default: 0
    t.integer  "install_order_notes_count", limit: 4,     default: 0
    t.integer  "compatibility_notes_count", limit: 4,     default: 0
    t.integer  "incorrect_notes_count",     limit: 4,     default: 0
    t.integer  "agreement_marks_count",     limit: 4,     default: 0
    t.integer  "submitted_mods_count",      limit: 4,     default: 0
    t.integer  "starred_mods_count",        limit: 4,     default: 0
    t.integer  "starred_mod_lists_count",   limit: 4,     default: 0
    t.integer  "submitted_comments_count",  limit: 4,     default: 0
    t.integer  "mod_stars_count",           limit: 4,     default: 0
    t.text     "about_me",                  limit: 65535
    t.integer  "load_order_notes_count",    limit: 4,     default: 0
    t.string   "invitation_token",          limit: 255
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer  "invitation_limit",          limit: 4
    t.integer  "invited_by_id",             limit: 4
    t.string   "invited_by_type",           limit: 255
    t.integer  "invitations_count",         limit: 4,     default: 0
    t.integer  "mod_lists_count",           limit: 4,     default: 0
    t.integer  "mod_collections_count",     limit: 4,     default: 0
    t.integer  "helpful_marks_count",       limit: 4,     default: 0
    t.integer  "tags_count",                limit: 4,     default: 0
    t.integer  "mod_tags_count",            limit: 4,     default: 0
    t.integer  "mod_list_tags_count",       limit: 4,     default: 0
    t.integer  "authored_mods_count",       limit: 4,     default: 0
  end

  add_index "users", ["active_mod_list_id"], name: "active_ml_id", using: :btree
  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["invitation_token"], name: "index_users_on_invitation_token", unique: true, using: :btree
  add_index "users", ["invitations_count"], name: "index_users_on_invitations_count", using: :btree
  add_index "users", ["invited_by_id"], name: "index_users_on_invited_by_id", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "workshop_infos", force: :cascade do |t|
    t.integer  "mod_id",            limit: 4
    t.string   "mod_name",          limit: 255
    t.string   "uploaded_by",       limit: 128
    t.string   "date_submitted",    limit: 255
    t.string   "date_updated",      limit: 255
    t.datetime "last_scraped"
    t.integer  "discussions_count", limit: 4,   default: 0
    t.integer  "comments_count",    limit: 4,   default: 0
    t.integer  "ratings_count",     limit: 4,   default: 0
    t.integer  "average_rating",    limit: 1,   default: 0
    t.integer  "views",             limit: 4,   default: 0
    t.integer  "subscribers",       limit: 4,   default: 0
    t.integer  "favorites",         limit: 4,   default: 0
    t.integer  "file_size",         limit: 4,   default: 0
    t.integer  "images_count",      limit: 4,   default: 0
    t.integer  "videos_count",      limit: 4,   default: 0
    t.boolean  "has_stats",                     default: false
  end

  add_index "workshop_infos", ["mod_id"], name: "fk_rails_8707144ad7", using: :btree

  add_foreign_key "agreement_marks", "incorrect_notes", name: "agreement_marks_ibfk_1"
  add_foreign_key "agreement_marks", "users", column: "submitted_by", name: "agreement_marks_ibfk_2"
  add_foreign_key "articles", "users", column: "submitted_by"
  add_foreign_key "asset_files", "games"
  add_foreign_key "categories", "categories", column: "parent_id"
  add_foreign_key "category_priorities", "categories", column: "dominant_id"
  add_foreign_key "category_priorities", "categories", column: "recessive_id"
  add_foreign_key "comments", "comments", column: "parent_comment", name: "comments_ibfk_1"
  add_foreign_key "comments", "users", column: "submitted_by", name: "comments_ibfk_2"
  add_foreign_key "compatibility_note_history_entries", "compatibility_notes"
  add_foreign_key "compatibility_note_history_entries", "mods", column: "compatibility_mod_id"
  add_foreign_key "compatibility_note_history_entries", "plugins", column: "compatibility_plugin_id"
  add_foreign_key "compatibility_note_history_entries", "users", column: "submitted_by"
  add_foreign_key "compatibility_notes", "games"
  add_foreign_key "compatibility_notes", "mods", column: "first_mod_id"
  add_foreign_key "compatibility_notes", "mods", column: "second_mod_id"
  add_foreign_key "compatibility_notes", "plugins", column: "compatibility_plugin_id", name: "compatibility_notes_ibfk_2"
  add_foreign_key "compatibility_notes", "users", column: "submitted_by", name: "compatibility_notes_ibfk_1"
  add_foreign_key "config_files", "games"
  add_foreign_key "dummy_masters", "plugins"
  add_foreign_key "helpful_marks", "users", column: "submitted_by", name: "helpful_marks_ibfk_4"
  add_foreign_key "incorrect_notes", "games"
  add_foreign_key "incorrect_notes", "users", column: "submitted_by", name: "incorrect_notes_ibfk_4"
  add_foreign_key "install_order_note_history_entries", "install_order_notes"
  add_foreign_key "install_order_note_history_entries", "users", column: "submitted_by"
  add_foreign_key "install_order_notes", "games"
  add_foreign_key "install_order_notes", "mods", column: "first_mod_id"
  add_foreign_key "install_order_notes", "mods", column: "second_mod_id"
  add_foreign_key "install_order_notes", "users", column: "submitted_by"
  add_foreign_key "load_order_note_history_entries", "load_order_notes"
  add_foreign_key "load_order_note_history_entries", "users", column: "submitted_by"
  add_foreign_key "load_order_notes", "games"
  add_foreign_key "load_order_notes", "plugins", column: "first_plugin_id"
  add_foreign_key "load_order_notes", "plugins", column: "second_plugin_id"
  add_foreign_key "load_order_notes", "users", column: "submitted_by"
  add_foreign_key "lover_infos", "games"
  add_foreign_key "lover_infos", "mods"
  add_foreign_key "masters", "plugins", name: "masters_ibfk_1"
  add_foreign_key "mod_asset_files", "asset_files"
  add_foreign_key "mod_asset_files", "mods"
  add_foreign_key "mod_authors", "mods", name: "mod_authors_ibfk_1"
  add_foreign_key "mod_authors", "users", name: "mod_authors_ibfk_2"
  add_foreign_key "mod_list_compatibility_notes", "compatibility_notes"
  add_foreign_key "mod_list_compatibility_notes", "mod_lists", name: "mod_list_compatibility_notes_ibfk_1"
  add_foreign_key "mod_list_config_files", "config_files"
  add_foreign_key "mod_list_config_files", "mod_lists"
  add_foreign_key "mod_list_custom_config_files", "mod_lists"
  add_foreign_key "mod_list_custom_plugins", "mod_lists", name: "mod_list_custom_plugins_ibfk_1"
  add_foreign_key "mod_list_install_order_notes", "install_order_notes"
  add_foreign_key "mod_list_install_order_notes", "mod_lists", name: "mod_list_install_order_notes_ibfk_1"
  add_foreign_key "mod_list_load_order_notes", "load_order_notes"
  add_foreign_key "mod_list_load_order_notes", "mod_lists"
  add_foreign_key "mod_list_mods", "mod_lists", name: "mod_list_mods_ibfk_1"
  add_foreign_key "mod_list_mods", "mods", name: "mod_list_mods_ibfk_2"
  add_foreign_key "mod_list_plugins", "mod_lists", name: "mod_list_plugins_ibfk_1"
  add_foreign_key "mod_list_plugins", "plugins", name: "mod_list_plugins_ibfk_2"
  add_foreign_key "mod_list_stars", "mod_lists", name: "mod_list_stars_ibfk_1"
  add_foreign_key "mod_list_stars", "users", name: "mod_list_stars_ibfk_2"
  add_foreign_key "mod_list_tags", "mod_lists"
  add_foreign_key "mod_list_tags", "tags"
  add_foreign_key "mod_list_tags", "users", column: "submitted_by"
  add_foreign_key "mod_lists", "games"
  add_foreign_key "mod_lists", "users", column: "created_by", name: "mod_lists_ibfk_1"
  add_foreign_key "mod_requirements", "mods"
  add_foreign_key "mod_requirements", "mods", column: "required_id"
  add_foreign_key "mod_stars", "mods", name: "mod_stars_ibfk_1"
  add_foreign_key "mod_stars", "users", name: "mod_stars_ibfk_2"
  add_foreign_key "mod_tags", "mods"
  add_foreign_key "mod_tags", "tags"
  add_foreign_key "mod_tags", "users", column: "submitted_by"
  add_foreign_key "mods", "categories", column: "primary_category_id"
  add_foreign_key "mods", "categories", column: "secondary_category_id"
  add_foreign_key "mods", "games"
  add_foreign_key "mods", "users", column: "submitted_by"
  add_foreign_key "nexus_infos", "games"
  add_foreign_key "override_records", "plugins", name: "override_records_ibfk_1"
  add_foreign_key "plugin_errors", "plugins"
  add_foreign_key "plugin_record_groups", "plugins", name: "plugin_record_groups_ibfk_1"
  add_foreign_key "plugins", "games"
  add_foreign_key "plugins", "mods"
  add_foreign_key "quotes", "games"
  add_foreign_key "record_groups", "games"
  add_foreign_key "reports", "base_reports"
  add_foreign_key "reports", "users", column: "submitted_by"
  add_foreign_key "reputation_links", "user_reputations", column: "from_rep_id", name: "reputation_links_ibfk_1"
  add_foreign_key "reputation_links", "user_reputations", column: "to_rep_id", name: "reputation_links_ibfk_2"
  add_foreign_key "review_ratings", "review_sections"
  add_foreign_key "review_ratings", "reviews"
  add_foreign_key "review_sections", "categories"
  add_foreign_key "reviews", "games"
  add_foreign_key "reviews", "mods", name: "reviews_ibfk_2"
  add_foreign_key "reviews", "users", column: "submitted_by", name: "reviews_ibfk_1"
  add_foreign_key "tags", "games"
  add_foreign_key "tags", "users", column: "submitted_by"
  add_foreign_key "user_bios", "users", name: "user_bios_ibfk_1"
  add_foreign_key "user_reputations", "users", name: "user_reputations_ibfk_1"
  add_foreign_key "user_settings", "users", name: "user_settings_ibfk_1"
  add_foreign_key "user_titles", "games"
  add_foreign_key "users", "mod_lists", column: "active_mod_list_id", name: "users_ibfk_4"
  add_foreign_key "workshop_infos", "mods"
end
