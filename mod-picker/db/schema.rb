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

ActiveRecord::Schema.define(version: 20161016055843) do

  create_table "agreement_marks", id: false, force: :cascade do |t|
    t.integer "correction_id", limit: 4,                null: false
    t.integer "submitted_by",  limit: 4,                null: false
    t.boolean "agree",                   default: true, null: false
  end

  add_index "agreement_marks", ["correction_id"], name: "inc_id", using: :btree
  add_index "agreement_marks", ["submitted_by"], name: "submitted_by", using: :btree

  create_table "articles", force: :cascade do |t|
    t.integer  "game_id",        limit: 4
    t.integer  "submitted_by",   limit: 4,                 null: false
    t.string   "title",          limit: 255,               null: false
    t.text     "text_body",      limit: 65535,             null: false
    t.integer  "comments_count", limit: 4,     default: 0, null: false
    t.datetime "submitted",                                null: false
    t.datetime "edited"
  end

  add_index "articles", ["submitted_by"], name: "fk_rails_ea02c233bd", using: :btree

  create_table "asset_files", force: :cascade do |t|
    t.integer "game_id",               limit: 4,               null: false
    t.string  "path",                  limit: 255,             null: false
    t.integer "mod_asset_files_count", limit: 4,   default: 0, null: false
  end

  add_index "asset_files", ["game_id"], name: "fk_rails_2e8fb86f89", using: :btree
  add_index "asset_files", ["path"], name: "filepath", unique: true, using: :btree

  create_table "base_reports", force: :cascade do |t|
    t.integer  "reportable_id",   limit: 4,               null: false
    t.string   "reportable_type", limit: 255,             null: false
    t.integer  "reports_count",   limit: 4,   default: 0, null: false
    t.datetime "submitted",                               null: false
    t.datetime "edited"
  end

  create_table "blacklisted_authors", force: :cascade do |t|
    t.string "source", limit: 32, null: false
    t.string "author", limit: 64, null: false
  end

  add_index "blacklisted_authors", ["author"], name: "index_blacklisted_authors_on_author", using: :btree
  add_index "blacklisted_authors", ["source"], name: "index_blacklisted_authors_on_source", using: :btree

  create_table "categories", force: :cascade do |t|
    t.integer "parent_id",   limit: 4
    t.string  "name",        limit: 64,              null: false
    t.string  "description", limit: 255,             null: false
    t.integer "priority",    limit: 4,   default: 0, null: false
  end

  add_index "categories", ["parent_id"], name: "fk_rails_82f48f7407", using: :btree

  create_table "category_priorities", id: false, force: :cascade do |t|
    t.integer "dominant_id",  limit: 4,   null: false
    t.integer "recessive_id", limit: 4,   null: false
    t.string  "description",  limit: 255, null: false
  end

  add_index "category_priorities", ["dominant_id"], name: "fk_rails_10799f2958", using: :btree
  add_index "category_priorities", ["recessive_id"], name: "fk_rails_d624be02b9", using: :btree

  create_table "comments", force: :cascade do |t|
    t.integer  "parent_id",         limit: 4
    t.integer  "submitted_by",      limit: 4,                     null: false
    t.integer  "commentable_id",    limit: 4,                     null: false
    t.string   "commentable_type",  limit: 255,                   null: false
    t.text     "text_body",         limit: 65535,                 null: false
    t.integer  "children_count",    limit: 4,     default: 0,     null: false
    t.boolean  "hidden",                          default: false, null: false
    t.boolean  "has_adult_content",               default: false, null: false
    t.datetime "submitted",                                       null: false
    t.datetime "edited"
  end

  add_index "comments", ["commentable_type", "commentable_id"], name: "index_comments_on_commentable_type_and_commentable_id", using: :btree
  add_index "comments", ["parent_id"], name: "parent_comment", using: :btree
  add_index "comments", ["submitted_by"], name: "submitted_by", using: :btree

  create_table "compatibility_note_history_entries", force: :cascade do |t|
    t.integer  "compatibility_note_id",   limit: 4,                 null: false
    t.integer  "edited_by",               limit: 4,                 null: false
    t.integer  "status",                  limit: 4,     default: 0, null: false
    t.integer  "compatibility_mod_id",    limit: 4
    t.integer  "compatibility_plugin_id", limit: 4
    t.text     "text_body",               limit: 65535,             null: false
    t.string   "edit_summary",            limit: 255,               null: false
    t.datetime "edited"
  end

  add_index "compatibility_note_history_entries", ["compatibility_mod_id"], name: "fk_rails_e1c933535e", using: :btree
  add_index "compatibility_note_history_entries", ["compatibility_note_id"], name: "fk_rails_4970df5c77", using: :btree
  add_index "compatibility_note_history_entries", ["compatibility_plugin_id"], name: "fk_rails_6466cbf704", using: :btree
  add_index "compatibility_note_history_entries", ["edited_by"], name: "fk_rails_7e4343a2d1", using: :btree

  create_table "compatibility_notes", force: :cascade do |t|
    t.integer  "game_id",                 limit: 4,                     null: false
    t.integer  "submitted_by",            limit: 4,                     null: false
    t.integer  "edited_by",               limit: 4
    t.integer  "corrector_id",            limit: 4
    t.integer  "status",                  limit: 4,     default: 0,     null: false
    t.integer  "first_mod_id",            limit: 4,                     null: false
    t.integer  "second_mod_id",           limit: 4,                     null: false
    t.integer  "compatibility_mod_id",    limit: 4
    t.integer  "compatibility_plugin_id", limit: 4
    t.text     "text_body",               limit: 65535,                 null: false
    t.string   "edit_summary",            limit: 255
    t.string   "moderator_message",       limit: 255
    t.float    "reputation",              limit: 24,    default: 0.0,   null: false
    t.integer  "standing",                limit: 1,     default: 0,     null: false
    t.integer  "helpful_count",           limit: 4,     default: 0,     null: false
    t.integer  "not_helpful_count",       limit: 4,     default: 0,     null: false
    t.integer  "corrections_count",       limit: 4,     default: 0,     null: false
    t.integer  "history_entries_count",   limit: 4,     default: 0,     null: false
    t.boolean  "approved",                              default: false, null: false
    t.datetime "edited"
    t.boolean  "hidden",                                default: false, null: false
    t.boolean  "has_adult_content",                     default: false, null: false
    t.datetime "submitted",                                             null: false
  end

  add_index "compatibility_notes", ["compatibility_plugin_id"], name: "compatibility_patch", using: :btree
  add_index "compatibility_notes", ["corrector_id"], name: "fk_rails_4dc9fad712", using: :btree
  add_index "compatibility_notes", ["edited_by"], name: "fk_rails_921b844a68", using: :btree
  add_index "compatibility_notes", ["first_mod_id"], name: "fk_rails_3524228f07", using: :btree
  add_index "compatibility_notes", ["game_id"], name: "fk_rails_c18131e78a", using: :btree
  add_index "compatibility_notes", ["second_mod_id"], name: "fk_rails_10dd0a50f6", using: :btree
  add_index "compatibility_notes", ["submitted_by"], name: "submitted_by", using: :btree

  create_table "config_files", force: :cascade do |t|
    t.integer "game_id",         limit: 4,                 null: false
    t.integer "mod_id",          limit: 4,                 null: false
    t.string  "filename",        limit: 64,                null: false
    t.string  "install_path",    limit: 128,               null: false
    t.text    "text_body",       limit: 65535
    t.integer "mod_lists_count", limit: 4,     default: 0, null: false
  end

  add_index "config_files", ["game_id", "filename"], name: "index_config_files_on_game_id_and_filename", using: :btree
  add_index "config_files", ["mod_id"], name: "fk_rails_241d26b9f7", using: :btree

  create_table "corrections", force: :cascade do |t|
    t.integer  "game_id",           limit: 4,                     null: false
    t.integer  "submitted_by",      limit: 4,                     null: false
    t.integer  "edited_by",         limit: 4
    t.integer  "correctable_id",    limit: 4,                     null: false
    t.string   "correctable_type",  limit: 255,                   null: false
    t.string   "title",             limit: 64
    t.text     "text_body",         limit: 65535,                 null: false
    t.integer  "status",            limit: 1,     default: 0,     null: false
    t.integer  "mod_status",        limit: 1
    t.integer  "agree_count",       limit: 4,     default: 0,     null: false
    t.integer  "disagree_count",    limit: 4,     default: 0,     null: false
    t.integer  "comments_count",    limit: 4,     default: 0,     null: false
    t.boolean  "hidden",                          default: false, null: false
    t.boolean  "has_adult_content",               default: false, null: false
    t.datetime "submitted",                                       null: false
    t.datetime "edited"
  end

  add_index "corrections", ["correctable_type", "correctable_id"], name: "index_corrections_on_correctable_type_and_correctable_id", using: :btree
  add_index "corrections", ["edited_by"], name: "fk_rails_aafc41fce4", using: :btree
  add_index "corrections", ["game_id"], name: "fk_rails_6d40e5f2cc", using: :btree
  add_index "corrections", ["submitted_by"], name: "submitted_by", using: :btree

  create_table "custom_sources", force: :cascade do |t|
    t.integer "mod_id", limit: 4,   null: false
    t.string  "label",  limit: 255
    t.string  "url",    limit: 255, null: false
  end

  add_index "custom_sources", ["mod_id"], name: "fk_rails_4da082b3d0", using: :btree

  create_table "dummy_masters", force: :cascade do |t|
    t.integer "plugin_id", limit: 4,   null: false
    t.integer "index",     limit: 1,   null: false
    t.string  "filename",  limit: 128, null: false
  end

  add_index "dummy_masters", ["plugin_id"], name: "fk_rails_2552b596d8", using: :btree

  create_table "events", force: :cascade do |t|
    t.integer  "user_id",      limit: 4
    t.integer  "content_id",   limit: 4,  null: false
    t.string   "content_type", limit: 32, null: false
    t.integer  "event_type",   limit: 1,  null: false
    t.datetime "created",                 null: false
  end

  add_index "events", ["user_id"], name: "fk_rails_0cb5590091", using: :btree

  create_table "games", force: :cascade do |t|
    t.integer "parent_game_id",            limit: 4
    t.string  "display_name",              limit: 32,              null: false
    t.string  "long_name",                 limit: 128,             null: false
    t.string  "abbr_name",                 limit: 32,              null: false
    t.string  "nexus_name",                limit: 16
    t.string  "exe_name",                  limit: 32
    t.string  "esm_name",                  limit: 32
    t.string  "steam_app_ids",             limit: 64
    t.integer "mods_count",                limit: 4,   default: 0, null: false
    t.integer "plugins_count",             limit: 4,   default: 0, null: false
    t.integer "asset_files_count",         limit: 4,   default: 0, null: false
    t.integer "nexus_infos_count",         limit: 4,   default: 0, null: false
    t.integer "lover_infos_count",         limit: 4,   default: 0, null: false
    t.integer "workshop_infos_count",      limit: 4,   default: 0, null: false
    t.integer "mod_lists_count",           limit: 4,   default: 0, null: false
    t.integer "config_files_count",        limit: 4,   default: 0, null: false
    t.integer "reviews_count",             limit: 4,   default: 0, null: false
    t.integer "compatibility_notes_count", limit: 4,   default: 0, null: false
    t.integer "install_order_notes_count", limit: 4,   default: 0, null: false
    t.integer "load_order_notes_count",    limit: 4,   default: 0, null: false
    t.integer "corrections_count",         limit: 4,   default: 0, null: false
    t.integer "help_pages_count",          limit: 4,   default: 0, null: false
  end

  add_index "games", ["parent_game_id"], name: "fk_rails_f750cfc2c5", using: :btree

  create_table "help_pages", force: :cascade do |t|
    t.integer  "game_id",        limit: 4
    t.integer  "category",       limit: 1,     default: 0, null: false
    t.integer  "submitted_by",   limit: 4,                 null: false
    t.string   "title",          limit: 128,               null: false
    t.text     "text_body",      limit: 65535,             null: false
    t.integer  "comments_count", limit: 4,     default: 0, null: false
    t.datetime "submitted",                                null: false
    t.datetime "edited"
  end

  add_index "help_pages", ["game_id"], name: "index_help_pages_on_game_id", using: :btree
  add_index "help_pages", ["submitted_by"], name: "fk_rails_01a3f94bf2", using: :btree

  create_table "helpful_marks", id: false, force: :cascade do |t|
    t.integer  "submitted_by",     limit: 4,                  null: false
    t.integer  "helpfulable_id",   limit: 4,                  null: false
    t.string   "helpfulable_type", limit: 255,                null: false
    t.boolean  "helpful",                      default: true, null: false
    t.datetime "submitted",                                   null: false
  end

  add_index "helpful_marks", ["helpfulable_type", "helpfulable_id"], name: "index_helpful_marks_on_helpfulable_type_and_helpfulable_id", using: :btree
  add_index "helpful_marks", ["submitted_by"], name: "submitted_by", using: :btree

  create_table "install_order_note_history_entries", force: :cascade do |t|
    t.integer  "install_order_note_id", limit: 4,     null: false
    t.integer  "edited_by",             limit: 4,     null: false
    t.text     "text_body",             limit: 65535, null: false
    t.string   "edit_summary",          limit: 255,   null: false
    t.datetime "edited"
  end

  add_index "install_order_note_history_entries", ["edited_by"], name: "fk_rails_18a032d0ac", using: :btree
  add_index "install_order_note_history_entries", ["install_order_note_id"], name: "fk_rails_f5643ed650", using: :btree

  create_table "install_order_notes", force: :cascade do |t|
    t.integer  "game_id",               limit: 4,                     null: false
    t.integer  "submitted_by",          limit: 4,                     null: false
    t.integer  "edited_by",             limit: 4
    t.integer  "corrector_id",          limit: 4
    t.integer  "first_mod_id",          limit: 4,                     null: false
    t.integer  "second_mod_id",         limit: 4,                     null: false
    t.text     "text_body",             limit: 65535,                 null: false
    t.string   "edit_summary",          limit: 255
    t.string   "moderator_message",     limit: 255
    t.float    "reputation",            limit: 24,    default: 0.0,   null: false
    t.integer  "standing",              limit: 1,     default: 0,     null: false
    t.integer  "helpful_count",         limit: 4,     default: 0,     null: false
    t.integer  "not_helpful_count",     limit: 4,     default: 0,     null: false
    t.integer  "corrections_count",     limit: 4,     default: 0,     null: false
    t.integer  "history_entries_count", limit: 4,     default: 0,     null: false
    t.boolean  "approved",                            default: false, null: false
    t.boolean  "hidden",                              default: false, null: false
    t.boolean  "has_adult_content",                   default: false, null: false
    t.datetime "submitted",                                           null: false
    t.datetime "edited"
  end

  add_index "install_order_notes", ["corrector_id"], name: "fk_rails_fc305db980", using: :btree
  add_index "install_order_notes", ["edited_by"], name: "fk_rails_a44dae8099", using: :btree
  add_index "install_order_notes", ["first_mod_id"], name: "fk_rails_bc30c8f58f", using: :btree
  add_index "install_order_notes", ["game_id"], name: "fk_rails_aa90c33b77", using: :btree
  add_index "install_order_notes", ["second_mod_id"], name: "fk_rails_b74bbcab8b", using: :btree
  add_index "install_order_notes", ["submitted_by"], name: "fk_rails_ea0bdedfde", using: :btree

  create_table "load_order_note_history_entries", force: :cascade do |t|
    t.integer  "load_order_note_id", limit: 4,     null: false
    t.integer  "edited_by",          limit: 4,     null: false
    t.text     "text_body",          limit: 65535, null: false
    t.string   "edit_summary",       limit: 255,   null: false
    t.datetime "edited"
  end

  add_index "load_order_note_history_entries", ["edited_by"], name: "fk_rails_478afef4a8", using: :btree
  add_index "load_order_note_history_entries", ["load_order_note_id"], name: "fk_rails_f99a4f8204", using: :btree

  create_table "load_order_notes", force: :cascade do |t|
    t.integer  "game_id",               limit: 4,                     null: false
    t.integer  "submitted_by",          limit: 4,                     null: false
    t.integer  "edited_by",             limit: 4
    t.integer  "corrector_id",          limit: 4
    t.integer  "first_plugin_id",       limit: 4,                     null: false
    t.integer  "second_plugin_id",      limit: 4,                     null: false
    t.text     "text_body",             limit: 65535,                 null: false
    t.string   "edit_summary",          limit: 255
    t.string   "moderator_message",     limit: 255
    t.float    "reputation",            limit: 24,    default: 0.0,   null: false
    t.integer  "standing",              limit: 1,     default: 0,     null: false
    t.integer  "helpful_count",         limit: 4,     default: 0,     null: false
    t.integer  "not_helpful_count",     limit: 4,     default: 0,     null: false
    t.integer  "corrections_count",     limit: 4,     default: 0,     null: false
    t.integer  "history_entries_count", limit: 4,     default: 0,     null: false
    t.boolean  "approved",                            default: false, null: false
    t.boolean  "hidden",                              default: false, null: false
    t.boolean  "has_adult_content",                   default: false, null: false
    t.datetime "submitted",                                           null: false
    t.datetime "edited"
  end

  add_index "load_order_notes", ["corrector_id"], name: "fk_rails_454b530bc3", using: :btree
  add_index "load_order_notes", ["edited_by"], name: "fk_rails_e2453073ea", using: :btree
  add_index "load_order_notes", ["first_plugin_id"], name: "fk_rails_d6c931c1cc", using: :btree
  add_index "load_order_notes", ["game_id"], name: "fk_rails_cd2fa42211", using: :btree
  add_index "load_order_notes", ["second_plugin_id"], name: "fk_rails_af9e3c9509", using: :btree
  add_index "load_order_notes", ["submitted_by"], name: "fk_rails_9992d700a9", using: :btree

  create_table "lover_infos", force: :cascade do |t|
    t.integer  "game_id",           limit: 4,                   null: false
    t.boolean  "has_stats",                     default: false, null: false
    t.datetime "last_scraped"
    t.integer  "mod_id",            limit: 4
    t.string   "mod_name",          limit: 255,                 null: false
    t.string   "uploaded_by",       limit: 128,                 null: false
    t.datetime "released",                                      null: false
    t.datetime "updated"
    t.string   "current_version",   limit: 32
    t.integer  "views",             limit: 4,   default: 0,     null: false
    t.integer  "downloads",         limit: 4,   default: 0,     null: false
    t.integer  "followers_count",   limit: 4,   default: 0,     null: false
    t.integer  "file_size",         limit: 4,   default: 0,     null: false
    t.boolean  "has_adult_content",             default: true,  null: false
  end

  add_index "lover_infos", ["game_id"], name: "fk_rails_0c0c747a5a", using: :btree
  add_index "lover_infos", ["mod_id"], name: "fk_rails_614a886dc0", using: :btree

  create_table "masters", id: false, force: :cascade do |t|
    t.integer "plugin_id",        limit: 4, null: false
    t.integer "master_plugin_id", limit: 4, null: false
    t.integer "index",            limit: 1, null: false
  end

  add_index "masters", ["master_plugin_id"], name: "fk_rails_00e5251b7c", using: :btree
  add_index "masters", ["plugin_id"], name: "pl_id", using: :btree

  create_table "messages", force: :cascade do |t|
    t.integer  "submitted_by", limit: 4,     null: false
    t.integer  "sent_to",      limit: 4
    t.text     "text",         limit: 65535, null: false
    t.datetime "submitted",                  null: false
    t.datetime "edited"
  end

  add_index "messages", ["sent_to"], name: "fk_rails_c6b55ed9a4", using: :btree
  add_index "messages", ["submitted_by"], name: "fk_rails_1364e4d956", using: :btree

  create_table "mod_asset_files", id: false, force: :cascade do |t|
    t.integer "mod_option_id", limit: 4,   null: false
    t.integer "asset_file_id", limit: 4
    t.string  "subpath",       limit: 255
  end

  add_index "mod_asset_files", ["asset_file_id"], name: "maf_id", using: :btree
  add_index "mod_asset_files", ["mod_option_id"], name: "mv_id", using: :btree

  create_table "mod_authors", force: :cascade do |t|
    t.integer "mod_id",  limit: 4,             null: false
    t.integer "user_id", limit: 4,             null: false
    t.integer "role",    limit: 1, default: 0, null: false
  end

  add_index "mod_authors", ["mod_id"], name: "mod_id", using: :btree
  add_index "mod_authors", ["user_id"], name: "user_id", using: :btree

  create_table "mod_list_config_files", force: :cascade do |t|
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

  create_table "mod_list_custom_mods", force: :cascade do |t|
    t.integer "mod_list_id", limit: 4,                     null: false
    t.integer "group_id",    limit: 4
    t.integer "index",       limit: 2,                     null: false
    t.boolean "is_utility",                default: false, null: false
    t.string  "name",        limit: 255,                   null: false
    t.text    "description", limit: 65535
  end

  add_index "mod_list_custom_mods", ["group_id"], name: "fk_rails_4c21862783", using: :btree
  add_index "mod_list_custom_mods", ["mod_list_id"], name: "fk_rails_a95ebb44e6", using: :btree

  create_table "mod_list_custom_plugins", force: :cascade do |t|
    t.integer "mod_list_id",           limit: 4,                     null: false
    t.integer "group_id",              limit: 4
    t.integer "index",                 limit: 2,                     null: false
    t.boolean "cleaned",                             default: false, null: false
    t.boolean "merged",                              default: false, null: false
    t.integer "compatibility_note_id", limit: 4
    t.string  "filename",              limit: 64,                    null: false
    t.text    "description",           limit: 65535
  end

  add_index "mod_list_custom_plugins", ["group_id"], name: "fk_rails_53bf719a81", using: :btree
  add_index "mod_list_custom_plugins", ["mod_list_id"], name: "ml_id", using: :btree

  create_table "mod_list_groups", force: :cascade do |t|
    t.integer "mod_list_id", limit: 4,                 null: false
    t.integer "index",       limit: 2,                 null: false
    t.integer "tab",         limit: 1,     default: 0, null: false
    t.integer "color",       limit: 1,     default: 0, null: false
    t.string  "name",        limit: 128,               null: false
    t.text    "description", limit: 65535
  end

  add_index "mod_list_groups", ["mod_list_id"], name: "fk_rails_0abd07c656", using: :btree

  create_table "mod_list_ignored_notes", force: :cascade do |t|
    t.integer "mod_list_id", limit: 4,   null: false
    t.integer "note_id",     limit: 4,   null: false
    t.string  "note_type",   limit: 255, null: false
  end

  add_index "mod_list_ignored_notes", ["mod_list_id"], name: "fk_rails_89a67a287a", using: :btree

  create_table "mod_list_mod_options", force: :cascade do |t|
    t.integer "mod_list_mod_id", limit: 4, null: false
    t.integer "mod_option_id",   limit: 4, null: false
  end

  add_index "mod_list_mod_options", ["mod_list_mod_id"], name: "fk_rails_bf4ca194fc", using: :btree
  add_index "mod_list_mod_options", ["mod_option_id"], name: "fk_rails_431e3255e3", using: :btree

  create_table "mod_list_mods", force: :cascade do |t|
    t.integer "mod_list_id", limit: 4, null: false
    t.integer "group_id",    limit: 4
    t.integer "mod_id",      limit: 4, null: false
    t.integer "index",       limit: 2, null: false
  end

  add_index "mod_list_mods", ["group_id"], name: "fk_rails_cb3cdf0fc4", using: :btree
  add_index "mod_list_mods", ["mod_id"], name: "mod_id", using: :btree
  add_index "mod_list_mods", ["mod_list_id"], name: "ml_id", using: :btree

  create_table "mod_list_plugins", force: :cascade do |t|
    t.integer "mod_list_id", limit: 4,                 null: false
    t.integer "group_id",    limit: 4
    t.integer "plugin_id",   limit: 4,                 null: false
    t.integer "index",       limit: 2,                 null: false
    t.boolean "cleaned",               default: false, null: false
    t.boolean "merged",                default: false, null: false
  end

  add_index "mod_list_plugins", ["group_id"], name: "fk_rails_8fbf03f255", using: :btree
  add_index "mod_list_plugins", ["mod_list_id"], name: "ml_id", using: :btree
  add_index "mod_list_plugins", ["plugin_id"], name: "pl_id", using: :btree

  create_table "mod_list_stars", id: false, force: :cascade do |t|
    t.integer "mod_list_id", limit: 4, null: false
    t.integer "user_id",     limit: 4, null: false
  end

  add_index "mod_list_stars", ["mod_list_id"], name: "ml_id", using: :btree
  add_index "mod_list_stars", ["user_id"], name: "user_id", using: :btree

  create_table "mod_list_tags", force: :cascade do |t|
    t.integer "mod_list_id",  limit: 4, null: false
    t.integer "tag_id",       limit: 4, null: false
    t.integer "submitted_by", limit: 4, null: false
  end

  add_index "mod_list_tags", ["mod_list_id"], name: "fk_rails_7de991735e", using: :btree
  add_index "mod_list_tags", ["submitted_by"], name: "fk_rails_4ab6737116", using: :btree
  add_index "mod_list_tags", ["tag_id"], name: "fk_rails_1632b7f954", using: :btree

  create_table "mod_lists", force: :cascade do |t|
    t.integer  "game_id",                   limit: 4,                     null: false
    t.integer  "submitted_by",              limit: 4,                     null: false
    t.integer  "edited_by",                 limit: 4
    t.integer  "status",                    limit: 1,     default: 0,     null: false
    t.integer  "visibility",                limit: 1,     default: 0,     null: false
    t.boolean  "is_collection",                           default: false, null: false
    t.string   "name",                      limit: 255,                   null: false
    t.text     "description",               limit: 65535
    t.integer  "tools_count",               limit: 4,     default: 0,     null: false
    t.integer  "mods_count",                limit: 4,     default: 0,     null: false
    t.integer  "custom_tools_count",        limit: 4,     default: 0,     null: false
    t.integer  "custom_mods_count",         limit: 4,     default: 0,     null: false
    t.integer  "plugins_count",             limit: 4,     default: 0,     null: false
    t.integer  "master_plugins_count",      limit: 4,     default: 0,     null: false
    t.integer  "available_plugins_count",   limit: 4,     default: 0,     null: false
    t.integer  "custom_plugins_count",      limit: 4,     default: 0,     null: false
    t.integer  "config_files_count",        limit: 4,     default: 0,     null: false
    t.integer  "custom_config_files_count", limit: 4,     default: 0,     null: false
    t.integer  "compatibility_notes_count", limit: 4,     default: 0,     null: false
    t.integer  "install_order_notes_count", limit: 4,     default: 0,     null: false
    t.integer  "load_order_notes_count",    limit: 4,     default: 0,     null: false
    t.integer  "ignored_notes_count",       limit: 4,     default: 0,     null: false
    t.integer  "bsa_files_count",           limit: 4,     default: 0,     null: false
    t.integer  "asset_files_count",         limit: 4,     default: 0,     null: false
    t.integer  "records_count",             limit: 4,     default: 0,     null: false
    t.integer  "override_records_count",    limit: 4,     default: 0,     null: false
    t.integer  "plugin_errors_count",       limit: 4,     default: 0,     null: false
    t.integer  "tags_count",                limit: 4,     default: 0,     null: false
    t.integer  "stars_count",               limit: 4,     default: 0,     null: false
    t.integer  "comments_count",            limit: 4,     default: 0,     null: false
    t.boolean  "disable_comments",                        default: false, null: false
    t.boolean  "lock_tags",                               default: false
    t.boolean  "has_adult_content",                       default: false, null: false
    t.boolean  "hidden",                                  default: false, null: false
    t.datetime "submitted",                                               null: false
    t.datetime "completed"
    t.datetime "updated"
  end

  add_index "mod_lists", ["edited_by"], name: "fk_rails_71c1af8d0c", using: :btree
  add_index "mod_lists", ["game_id"], name: "fk_rails_f25cbc0432", using: :btree
  add_index "mod_lists", ["submitted_by"], name: "created_by", using: :btree

  create_table "mod_options", force: :cascade do |t|
    t.integer "mod_id",            limit: 4,                   null: false
    t.string  "name",              limit: 128,                 null: false
    t.string  "display_name",      limit: 128,                 null: false
    t.integer "size",              limit: 8,   default: 0,     null: false
    t.boolean "default",                       default: false, null: false
    t.boolean "is_fomod_option",               default: false, null: false
    t.integer "asset_files_count", limit: 4,   default: 0,     null: false
    t.integer "plugins_count",     limit: 4,   default: 0,     null: false
  end

  add_index "mod_options", ["mod_id"], name: "fk_rails_e37829130d", using: :btree

  create_table "mod_requirements", force: :cascade do |t|
    t.integer "mod_id",      limit: 4, null: false
    t.integer "required_id", limit: 4, null: false
  end

  add_index "mod_requirements", ["mod_id"], name: "fk_rails_5a311577a9", using: :btree
  add_index "mod_requirements", ["required_id"], name: "fk_rails_05046fa6e5", using: :btree

  create_table "mod_stars", id: false, force: :cascade do |t|
    t.integer "mod_id",  limit: 4, null: false
    t.integer "user_id", limit: 4, null: false
  end

  add_index "mod_stars", ["mod_id"], name: "mod_id", using: :btree
  add_index "mod_stars", ["user_id"], name: "user_id", using: :btree

  create_table "mod_tags", force: :cascade do |t|
    t.integer "mod_id",       limit: 4, null: false
    t.integer "tag_id",       limit: 4, null: false
    t.integer "submitted_by", limit: 4, null: false
  end

  add_index "mod_tags", ["mod_id"], name: "fk_rails_5ab248dd85", using: :btree
  add_index "mod_tags", ["submitted_by"], name: "fk_rails_ad8ec1982c", using: :btree
  add_index "mod_tags", ["tag_id"], name: "fk_rails_ffd7f5019d", using: :btree

  create_table "mods", force: :cascade do |t|
    t.integer  "game_id",                   limit: 4,                   null: false
    t.integer  "submitted_by",              limit: 4,                   null: false
    t.integer  "edited_by",                 limit: 4
    t.boolean  "is_official",                           default: false, null: false
    t.boolean  "is_utility",                            default: false, null: false
    t.string   "name",                      limit: 128,                 null: false
    t.string   "aliases",                   limit: 128
    t.string   "authors",                   limit: 128,                 null: false
    t.integer  "status",                    limit: 1,   default: 0,     null: false
    t.integer  "primary_category_id",       limit: 4
    t.integer  "secondary_category_id",     limit: 4
    t.float    "average_rating",            limit: 24,  default: 0.0,   null: false
    t.float    "reputation",                limit: 24,  default: 0.0,   null: false
    t.integer  "plugins_count",             limit: 4,   default: 0,     null: false
    t.integer  "asset_files_count",         limit: 4,   default: 0,     null: false
    t.integer  "required_mods_count",       limit: 4,   default: 0,     null: false
    t.integer  "required_by_count",         limit: 4,   default: 0,     null: false
    t.integer  "tags_count",                limit: 4,   default: 0,     null: false
    t.integer  "stars_count",               limit: 4,   default: 0,     null: false
    t.integer  "mod_lists_count",           limit: 4,   default: 0,     null: false
    t.integer  "reviews_count",             limit: 4,   default: 0,     null: false
    t.integer  "compatibility_notes_count", limit: 4,   default: 0,     null: false
    t.integer  "install_order_notes_count", limit: 4,   default: 0,     null: false
    t.integer  "load_order_notes_count",    limit: 4,   default: 0,     null: false
    t.integer  "corrections_count",         limit: 4,   default: 0,     null: false
    t.boolean  "disallow_contributors",                 default: false, null: false
    t.boolean  "disable_reviews",                       default: false, null: false
    t.boolean  "lock_tags",                             default: false, null: false
    t.boolean  "has_adult_content",                     default: false, null: false
    t.boolean  "hidden",                                default: false, null: false
    t.datetime "released",                                              null: false
    t.datetime "updated"
    t.datetime "submitted",                                             null: false
  end

  add_index "mods", ["edited_by"], name: "fk_rails_9ec1af790b", using: :btree
  add_index "mods", ["game_id"], name: "fk_rails_3ec448a848", using: :btree
  add_index "mods", ["primary_category_id"], name: "fk_rails_42759f5da5", using: :btree
  add_index "mods", ["secondary_category_id"], name: "fk_rails_26f394ea9d", using: :btree
  add_index "mods", ["submitted_by"], name: "fk_rails_5f28cca69a", using: :btree

  create_table "nexus_infos", force: :cascade do |t|
    t.integer  "game_id",             limit: 4,                   null: false
    t.boolean  "has_stats",                       default: false, null: false
    t.datetime "last_scraped"
    t.integer  "mod_id",              limit: 4
    t.string   "mod_name",            limit: 255
    t.string   "uploaded_by",         limit: 128,                 null: false
    t.string   "authors",             limit: 128
    t.datetime "released"
    t.datetime "updated"
    t.string   "current_version",     limit: 32
    t.integer  "nexus_category",      limit: 4
    t.integer  "views",               limit: 4,   default: 0,     null: false
    t.integer  "downloads",           limit: 4,   default: 0,     null: false
    t.integer  "endorsements",        limit: 4,   default: 0,     null: false
    t.integer  "unique_downloads",    limit: 4,   default: 0,     null: false
    t.integer  "posts_count",         limit: 4,   default: 0,     null: false
    t.integer  "discussions_count",   limit: 4,   default: 0,     null: false
    t.integer  "articles_count",      limit: 4,   default: 0,     null: false
    t.integer  "bugs_count",          limit: 4,   default: 0,     null: false
    t.integer  "files_count",         limit: 4,   default: 0,     null: false
    t.integer  "images_count",        limit: 4,   default: 0,     null: false
    t.integer  "videos_count",        limit: 4,   default: 0,     null: false
    t.boolean  "has_adult_content",               default: false, null: false
    t.float    "endorsement_rate",    limit: 24,  default: 0.0,   null: false
    t.float    "dl_rate",             limit: 24,  default: 0.0,   null: false
    t.float    "udl_to_endorsements", limit: 24,  default: 0.0,   null: false
    t.float    "udl_to_posts",        limit: 24,  default: 0.0,   null: false
    t.float    "tdl_to_udl",          limit: 24,  default: 0.0,   null: false
    t.float    "views_to_tdl",        limit: 24,  default: 0.0,   null: false
  end

  add_index "nexus_infos", ["game_id"], name: "fk_rails_46e3032463", using: :btree

  create_table "notifications", id: false, force: :cascade do |t|
    t.integer "event_id", limit: 4,                 null: false
    t.integer "user_id",  limit: 4,                 null: false
    t.boolean "read",               default: false, null: false
  end

  add_index "notifications", ["event_id"], name: "fk_rails_edea501a4e", using: :btree
  add_index "notifications", ["user_id"], name: "fk_rails_494a5579c9", using: :btree

  create_table "override_records", id: false, force: :cascade do |t|
    t.integer "plugin_id", limit: 4, null: false
    t.integer "fid",       limit: 4, null: false
    t.string  "sig",       limit: 4, null: false
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
    t.integer "plugin_id",      limit: 4, null: false
    t.string  "sig",            limit: 4, null: false
    t.integer "record_count",   limit: 4, null: false
    t.integer "override_count", limit: 4, null: false
  end

  add_index "plugin_record_groups", ["plugin_id"], name: "pl_id", using: :btree

  create_table "plugins", force: :cascade do |t|
    t.integer "game_id",                limit: 4,               null: false
    t.integer "mod_option_id",          limit: 4
    t.string  "filename",               limit: 64,              null: false
    t.string  "crc_hash",               limit: 8,               null: false
    t.integer "file_size",              limit: 4,               null: false
    t.string  "author",                 limit: 128
    t.string  "description",            limit: 512
    t.integer "record_count",           limit: 4,   default: 0, null: false
    t.integer "override_count",         limit: 4,   default: 0, null: false
    t.integer "errors_count",           limit: 4,   default: 0, null: false
    t.integer "mod_lists_count",        limit: 4,   default: 0, null: false
    t.integer "load_order_notes_count", limit: 4,   default: 0, null: false
  end

  add_index "plugins", ["game_id"], name: "fk_rails_5a7ba47709", using: :btree
  add_index "plugins", ["mod_option_id"], name: "mv_id", using: :btree

  create_table "quotes", force: :cascade do |t|
    t.integer "game_id", limit: 4,   null: false
    t.string  "text",    limit: 255, null: false
    t.string  "label",   limit: 32,  null: false
  end

  add_index "quotes", ["game_id"], name: "fk_rails_273247f4b3", using: :btree

  create_table "record_groups", force: :cascade do |t|
    t.integer "game_id",     limit: 4,                  null: false
    t.string  "signature",   limit: 4,                  null: false
    t.string  "name",        limit: 64,                 null: false
    t.boolean "child_group",            default: false, null: false
  end

  add_index "record_groups", ["game_id", "signature"], name: "index_record_groups_on_game_id_and_signature", unique: true, using: :btree

  create_table "reports", force: :cascade do |t|
    t.integer  "base_report_id", limit: 4,   null: false
    t.integer  "submitted_by",   limit: 4,   null: false
    t.integer  "reason",         limit: 1,   null: false
    t.string   "note",           limit: 128
    t.datetime "submitted",                  null: false
    t.datetime "edited"
  end

  add_index "reports", ["base_report_id"], name: "fk_rails_619eb511d7", using: :btree
  add_index "reports", ["submitted_by"], name: "fk_rails_41fbf0e712", using: :btree

  create_table "reputation_links", force: :cascade do |t|
    t.integer "from_rep_id", limit: 4, null: false
    t.integer "to_rep_id",   limit: 4, null: false
  end

  add_index "reputation_links", ["from_rep_id"], name: "from_rep_id", using: :btree
  add_index "reputation_links", ["to_rep_id"], name: "to_rep_id", using: :btree

  create_table "review_ratings", id: false, force: :cascade do |t|
    t.integer "review_id",         limit: 4, null: false
    t.integer "review_section_id", limit: 4, null: false
    t.integer "rating",            limit: 1, null: false
  end

  add_index "review_ratings", ["review_id"], name: "fk_rails_9b82eee8c2", using: :btree
  add_index "review_ratings", ["review_section_id"], name: "fk_rails_60e75c535e", using: :btree

  create_table "review_sections", force: :cascade do |t|
    t.integer "category_id", limit: 4,                   null: false
    t.string  "name",        limit: 32,                  null: false
    t.string  "prompt",      limit: 255,                 null: false
    t.boolean "default",                 default: false, null: false
  end

  add_index "review_sections", ["category_id"], name: "fk_rails_82a032f049", using: :btree

  create_table "reviews", force: :cascade do |t|
    t.integer  "game_id",           limit: 4,                     null: false
    t.integer  "submitted_by",      limit: 4,                     null: false
    t.integer  "edited_by",         limit: 4
    t.integer  "mod_id",            limit: 4,                     null: false
    t.text     "text_body",         limit: 65535,                 null: false
    t.string   "edit_summary",      limit: 255
    t.string   "moderator_message", limit: 255
    t.float    "overall_rating",    limit: 24,    default: 0.0,   null: false
    t.float    "reputation",        limit: 24,    default: 0.0,   null: false
    t.integer  "helpful_count",     limit: 4,     default: 0,     null: false
    t.integer  "not_helpful_count", limit: 4,     default: 0,     null: false
    t.integer  "ratings_count",     limit: 4,     default: 0,     null: false
    t.boolean  "approved",                        default: false, null: false
    t.boolean  "hidden",                          default: false, null: false
    t.boolean  "has_adult_content",               default: false, null: false
    t.datetime "submitted",                                       null: false
    t.datetime "edited"
  end

  add_index "reviews", ["edited_by"], name: "fk_rails_0fcc18e954", using: :btree
  add_index "reviews", ["game_id"], name: "fk_rails_dfb9dc48b4", using: :btree
  add_index "reviews", ["mod_id"], name: "mod_id", using: :btree
  add_index "reviews", ["submitted_by"], name: "submitted_by", using: :btree

  create_table "tags", force: :cascade do |t|
    t.integer "game_id",         limit: 4,                  null: false
    t.integer "submitted_by",    limit: 4,                  null: false
    t.string  "text",            limit: 32,                 null: false
    t.integer "mods_count",      limit: 4,  default: 0,     null: false
    t.integer "mod_lists_count", limit: 4,  default: 0,     null: false
    t.boolean "hidden",                     default: false, null: false
  end

  add_index "tags", ["game_id"], name: "fk_rails_21222987c6", using: :btree
  add_index "tags", ["submitted_by"], name: "fk_rails_8c7521065c", using: :btree

  create_table "user_bios", force: :cascade do |t|
    t.integer "user_id",                     limit: 4,              null: false
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
    t.integer  "user_id",          limit: 4,                  null: false
    t.float    "overall",          limit: 24, default: 5.0,   null: false
    t.float    "offset",           limit: 24, default: 5.0,   null: false
    t.float    "site_rep",         limit: 24, default: 0.0,   null: false
    t.float    "contribution_rep", limit: 24, default: 0.0,   null: false
    t.float    "author_rep",       limit: 24, default: 0.0,   null: false
    t.float    "given_rep",        limit: 24, default: 0.0,   null: false
    t.integer  "rep_from_count",   limit: 4,  default: 0,     null: false
    t.integer  "rep_to_count",     limit: 4,  default: 0,     null: false
    t.datetime "last_computed"
    t.boolean  "dont_compute",                default: false, null: false
  end

  add_index "user_reputations", ["user_id"], name: "user_id", using: :btree

  create_table "user_settings", force: :cascade do |t|
    t.integer "user_id",              limit: 4,                  null: false
    t.string  "theme",                limit: 64
    t.boolean "allow_comments",                  default: true,  null: false
    t.boolean "show_notifications",              default: true,  null: false
    t.boolean "email_notifications",             default: false, null: false
    t.boolean "email_public",                    default: false, null: false
    t.boolean "allow_adult_content",             default: false, null: false
    t.boolean "allow_nexus_mods",                default: true,  null: false
    t.boolean "allow_lovers_lab",                default: true,  null: false
    t.boolean "allow_steam_workshop",            default: true,  null: false
    t.boolean "enable_spellcheck",               default: true,  null: false
  end

  add_index "user_settings", ["user_id"], name: "user_id", using: :btree

  create_table "user_titles", force: :cascade do |t|
    t.integer "game_id",      limit: 4,  null: false
    t.string  "title",        limit: 32, null: false
    t.integer "rep_required", limit: 4,  null: false
  end

  add_index "user_titles", ["game_id"], name: "fk_rails_4a6dc16a81", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "username",                  limit: 32
    t.string   "email",                     limit: 255,   default: "", null: false
    t.string   "role",                      limit: 16,                 null: false
    t.string   "title",                     limit: 32
    t.integer  "active_mod_list_id",        limit: 4
    t.text     "about_me",                  limit: 65535
    t.integer  "comments_count",            limit: 4,     default: 0,  null: false
    t.integer  "authored_mods_count",       limit: 4,     default: 0,  null: false
    t.integer  "submitted_mods_count",      limit: 4,     default: 0,  null: false
    t.integer  "reviews_count",             limit: 4,     default: 0,  null: false
    t.integer  "compatibility_notes_count", limit: 4,     default: 0,  null: false
    t.integer  "install_order_notes_count", limit: 4,     default: 0,  null: false
    t.integer  "load_order_notes_count",    limit: 4,     default: 0,  null: false
    t.integer  "corrections_count",         limit: 4,     default: 0,  null: false
    t.integer  "submitted_comments_count",  limit: 4,     default: 0,  null: false
    t.integer  "mod_lists_count",           limit: 4,     default: 0,  null: false
    t.integer  "mod_collections_count",     limit: 4,     default: 0,  null: false
    t.integer  "tags_count",                limit: 4,     default: 0,  null: false
    t.integer  "mod_tags_count",            limit: 4,     default: 0,  null: false
    t.integer  "mod_list_tags_count",       limit: 4,     default: 0,  null: false
    t.integer  "helpful_marks_count",       limit: 4,     default: 0,  null: false
    t.integer  "agreement_marks_count",     limit: 4,     default: 0,  null: false
    t.integer  "starred_mods_count",        limit: 4,     default: 0,  null: false
    t.integer  "starred_mod_lists_count",   limit: 4,     default: 0,  null: false
    t.datetime "joined",                                               null: false
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
    t.integer  "mod_stars_count",           limit: 4,     default: 0
    t.string   "invitation_token",          limit: 255
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer  "invitation_limit",          limit: 4
    t.integer  "invited_by_id",             limit: 4
    t.string   "invited_by_type",           limit: 255
    t.integer  "invitations_count",         limit: 4,     default: 0
  end

  add_index "users", ["active_mod_list_id"], name: "active_ml_id", using: :btree
  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["invitation_token"], name: "index_users_on_invitation_token", unique: true, using: :btree
  add_index "users", ["invitations_count"], name: "index_users_on_invitations_count", using: :btree
  add_index "users", ["invited_by_id"], name: "index_users_on_invited_by_id", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "workshop_infos", force: :cascade do |t|
    t.integer  "game_id",           limit: 4,                   null: false
    t.boolean  "has_stats",                     default: false, null: false
    t.datetime "last_scraped"
    t.integer  "mod_id",            limit: 4
    t.string   "mod_name",          limit: 255,                 null: false
    t.string   "uploaded_by",       limit: 128,                 null: false
    t.datetime "released",                                      null: false
    t.datetime "updated"
    t.integer  "views",             limit: 4,   default: 0,     null: false
    t.integer  "subscribers",       limit: 4,   default: 0,     null: false
    t.integer  "favorites",         limit: 4,   default: 0,     null: false
    t.integer  "file_size",         limit: 4,   default: 0,     null: false
    t.integer  "posts_count",       limit: 4,   default: 0,     null: false
    t.integer  "discussions_count", limit: 4,   default: 0,     null: false
    t.integer  "images_count",      limit: 4,   default: 0,     null: false
    t.integer  "videos_count",      limit: 4,   default: 0,     null: false
  end

  add_index "workshop_infos", ["mod_id"], name: "fk_rails_8707144ad7", using: :btree

  add_foreign_key "agreement_marks", "corrections"
  add_foreign_key "agreement_marks", "users", column: "submitted_by", name: "agreement_marks_ibfk_2"
  add_foreign_key "articles", "users", column: "submitted_by"
  add_foreign_key "asset_files", "games"
  add_foreign_key "categories", "categories", column: "parent_id"
  add_foreign_key "category_priorities", "categories", column: "dominant_id"
  add_foreign_key "category_priorities", "categories", column: "recessive_id"
  add_foreign_key "comments", "comments", column: "parent_id", name: "comments_ibfk_1"
  add_foreign_key "comments", "users", column: "submitted_by", name: "comments_ibfk_2"
  add_foreign_key "compatibility_note_history_entries", "compatibility_notes"
  add_foreign_key "compatibility_note_history_entries", "mods", column: "compatibility_mod_id"
  add_foreign_key "compatibility_note_history_entries", "plugins", column: "compatibility_plugin_id"
  add_foreign_key "compatibility_note_history_entries", "users", column: "edited_by"
  add_foreign_key "compatibility_notes", "games"
  add_foreign_key "compatibility_notes", "mods", column: "first_mod_id"
  add_foreign_key "compatibility_notes", "mods", column: "second_mod_id"
  add_foreign_key "compatibility_notes", "plugins", column: "compatibility_plugin_id", name: "compatibility_notes_ibfk_2"
  add_foreign_key "compatibility_notes", "users", column: "corrector_id"
  add_foreign_key "compatibility_notes", "users", column: "edited_by"
  add_foreign_key "compatibility_notes", "users", column: "submitted_by", name: "compatibility_notes_ibfk_1"
  add_foreign_key "config_files", "games"
  add_foreign_key "config_files", "mods"
  add_foreign_key "corrections", "games"
  add_foreign_key "corrections", "users", column: "edited_by"
  add_foreign_key "corrections", "users", column: "submitted_by", name: "corrections_ibfk_4"
  add_foreign_key "custom_sources", "mods"
  add_foreign_key "dummy_masters", "plugins"
  add_foreign_key "events", "users"
  add_foreign_key "games", "games", column: "parent_game_id"
  add_foreign_key "help_pages", "games"
  add_foreign_key "help_pages", "users", column: "submitted_by"
  add_foreign_key "helpful_marks", "users", column: "submitted_by", name: "helpful_marks_ibfk_4"
  add_foreign_key "install_order_note_history_entries", "install_order_notes"
  add_foreign_key "install_order_note_history_entries", "users", column: "edited_by"
  add_foreign_key "install_order_notes", "games"
  add_foreign_key "install_order_notes", "mods", column: "first_mod_id"
  add_foreign_key "install_order_notes", "mods", column: "second_mod_id"
  add_foreign_key "install_order_notes", "users", column: "corrector_id"
  add_foreign_key "install_order_notes", "users", column: "edited_by"
  add_foreign_key "install_order_notes", "users", column: "submitted_by"
  add_foreign_key "load_order_note_history_entries", "load_order_notes"
  add_foreign_key "load_order_note_history_entries", "users", column: "edited_by"
  add_foreign_key "load_order_notes", "games"
  add_foreign_key "load_order_notes", "plugins", column: "first_plugin_id"
  add_foreign_key "load_order_notes", "plugins", column: "second_plugin_id"
  add_foreign_key "load_order_notes", "users", column: "corrector_id"
  add_foreign_key "load_order_notes", "users", column: "edited_by"
  add_foreign_key "load_order_notes", "users", column: "submitted_by"
  add_foreign_key "lover_infos", "games"
  add_foreign_key "lover_infos", "mods"
  add_foreign_key "masters", "plugins", column: "master_plugin_id"
  add_foreign_key "masters", "plugins", name: "masters_ibfk_1"
  add_foreign_key "messages", "users", column: "sent_to"
  add_foreign_key "messages", "users", column: "submitted_by"
  add_foreign_key "mod_asset_files", "asset_files"
  add_foreign_key "mod_asset_files", "mod_options"
  add_foreign_key "mod_authors", "mods", name: "mod_authors_ibfk_1"
  add_foreign_key "mod_authors", "users", name: "mod_authors_ibfk_2"
  add_foreign_key "mod_list_config_files", "config_files"
  add_foreign_key "mod_list_config_files", "mod_lists"
  add_foreign_key "mod_list_custom_config_files", "mod_lists"
  add_foreign_key "mod_list_custom_mods", "mod_list_groups", column: "group_id"
  add_foreign_key "mod_list_custom_mods", "mod_lists"
  add_foreign_key "mod_list_custom_plugins", "mod_list_groups", column: "group_id"
  add_foreign_key "mod_list_custom_plugins", "mod_lists", name: "mod_list_custom_plugins_ibfk_1"
  add_foreign_key "mod_list_groups", "mod_lists"
  add_foreign_key "mod_list_ignored_notes", "mod_lists"
  add_foreign_key "mod_list_mod_options", "mod_list_mods"
  add_foreign_key "mod_list_mod_options", "mod_options"
  add_foreign_key "mod_list_mods", "mod_list_groups", column: "group_id"
  add_foreign_key "mod_list_mods", "mod_lists", name: "mod_list_mods_ibfk_1"
  add_foreign_key "mod_list_mods", "mods", name: "mod_list_mods_ibfk_2"
  add_foreign_key "mod_list_plugins", "mod_list_groups", column: "group_id"
  add_foreign_key "mod_list_plugins", "mod_lists", name: "mod_list_plugins_ibfk_1"
  add_foreign_key "mod_list_plugins", "plugins", name: "mod_list_plugins_ibfk_2"
  add_foreign_key "mod_list_stars", "mod_lists", name: "mod_list_stars_ibfk_1"
  add_foreign_key "mod_list_stars", "users", name: "mod_list_stars_ibfk_2"
  add_foreign_key "mod_list_tags", "mod_lists"
  add_foreign_key "mod_list_tags", "tags"
  add_foreign_key "mod_list_tags", "users", column: "submitted_by"
  add_foreign_key "mod_lists", "games"
  add_foreign_key "mod_lists", "users", column: "edited_by"
  add_foreign_key "mod_lists", "users", column: "submitted_by"
  add_foreign_key "mod_options", "mods"
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
  add_foreign_key "mods", "users", column: "edited_by"
  add_foreign_key "mods", "users", column: "submitted_by"
  add_foreign_key "nexus_infos", "games"
  add_foreign_key "notifications", "events"
  add_foreign_key "notifications", "users"
  add_foreign_key "override_records", "plugins", name: "override_records_ibfk_1"
  add_foreign_key "plugin_errors", "plugins"
  add_foreign_key "plugin_record_groups", "plugins", name: "plugin_record_groups_ibfk_1"
  add_foreign_key "plugins", "games"
  add_foreign_key "plugins", "mod_options"
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
  add_foreign_key "reviews", "users", column: "edited_by"
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
