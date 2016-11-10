require 'rails_helper'

# create_table "compatibility_note_history_entries", force: :cascade do |t|
#     t.integer  "compatibility_note_id",   limit: 4,                 null: false
#     t.string   "edit_summary",            limit: 255,               null: false
#     t.integer  "submitted_by",            limit: 4,                 null: false
#     t.integer  "compatibility_mod_id",    limit: 4
#     t.integer  "compatibility_plugin_id", limit: 4
#     t.integer  "compatibility_type",      limit: 1,     default: 0, null: false
#     t.datetime "submitted"
#     t.datetime "edited"
#     t.text     "text_body",               limit: 65535
#   end

#   add_index "compatibility_note_history_entries", ["compatibility_mod_id"], name: "fk_rails_e1c933535e", using: :btree
#   add_index "compatibility_note_history_entries", ["compatibility_note_id"], name: "fk_rails_4970df5c77", using: :btree
#   add_index "compatibility_note_history_entries", ["compatibility_plugin_id"], name: "fk_rails_6466cbf704", using: :btree
#   add_index "compatibility_note_history_entries", ["submitted_by"], name: "fk_rails_7e4343a2d1", using: :btree

RSpec.describe CompatibilityNoteHistoryEntry, :model do
  fixtures :compatibility_note_history_entries, :users

  it "should have a valid fixture" do
    expect(compatibility_note_history_entries(:history_note_apocalypse)).to be_valid
  end

  it "should have valid factory parameters" do
    note = build(:compatibility_note_history_entry)

    note.valid?
    expect(note).to be_valid
    expect(build(:compatibility_note_history_entry)).to be_valid
  end

  it "should have a valid factory" do
    expect(create(:compatibility_note_history_entry)).to be_valid
  end
end
