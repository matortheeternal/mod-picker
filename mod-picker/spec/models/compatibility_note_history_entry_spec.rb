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
  fixtures :compatibility_note_history_entries

  it "should have a valid fixture" do
    expect(compatibility_note_history_entries(:history_note_apocalypse)).to be_valid
  end

  it "should have a valid factory" do
    expect(create(:compatibility_note_history_entry)).to be_valid
  end

  context "validations" do
    describe "compatibility_note_id" do
      it "should be invalid if empty" do
        note = build(:compatibility_note_history_entry,
                compatibility_note_id: nil)
        
        note.valid?
        expect(note.errors[:compatibility_note_id]).to include("can't be blank") 
      end
    end

    describe "edit_summary" do
      it "should be invalid if an empty string" do
        note = build(:compatibility_note_history_entry)

        invalidShortLengths = [("b" * 0), nil]

        invalidShortLengths.each do |text|
          note.edit_summary = text
          expect(note).to be_invalid
          expect(note.errors[:edit_summary]).to include("can't be blank")
        end
      end

      it "should be invalid length > 255" do
        note = build(:compatibility_note_history_entry)

        invalidShortLengths = [("b" * 256), ("f" * 300)]

        invalidShortLengths.each do |text|
          note.edit_summary = text
          expect(note).to be_invalid
          expect(note.errors[:edit_summary]).to include("is too long (maximum is 255 characters)")
        end
      end

    end

    describe "submitted_by" do
      it "should be invalid if empty" do
        note = build(:compatibility_note_history_entry,
                submitted_by: nil)
        
        note.valid?
        expect(note.errors[:submitted_by]).to include("can't be blank") 
      end
    end

    describe "compatibility_type" do
      let(:valid_list){ [:incompatible, :"partially incompatible", :"compatibility mod", :"compatibility option", :"make custom patch"] }
      it "should be valid if using valid compatibility_type enum" do
        valid_list.each_with_index do |item, index|
          expect(create(:compatibility_note_history_entry, compatibility_type: index)).to be_valid
        end
      end

      # error message is in sql and only partial checking is done
      # Non integer values will also give the same error message
      it "should be invalid if nil" do
        expect{ create(:compatibility_note_history_entry, compatibility_type: nil) }
          .to raise_error(ActiveRecord::StatementInvalid)
          .with_message(/Column 'compatibility_type' cannot be null/)
      end
    end

    describe "submitted" do
      it "should be invalid if empty" do
        note = build(:compatibility_note_history_entry,
                submitted: nil)
        
        note.valid?
        expect(note.errors[:submitted]).to include("can't be blank") 
      end

      it "should default to Datetime.now" do
        expect(create(:compatibility_note_history_entry).submitted)
          .to be_within(1.minute).of DateTime.now
      end
    end

    describe "text_body" do
      it "should be valid if 64 < Length < 16384" do
        note = build(:compatibility_note_history_entry)

        validLengths = [("a" * 64), ("b" * 16384), ("c" * 10123), ("d" * 3400)]

        validLengths.each do |text|
          note.text_body = text
          expect(note).to be_valid
        end
      end

      # testing short/nil/blank lengths separate from longer ones to test for individual error messages
      it "should be invalid if length < 64" do
        note = build(:compatibility_note_history_entry)

        invalidShortLengths = [("a" * 63), ("b" * 0), nil]

        invalidShortLengths.each do |text|
          note.text_body = text
          expect(note).to be_invalid
          expect(note.errors[:text_body]).to include("is too short (minimum is 64 characters)")
        end
      end

      it "should be invalid if length > 16384" do
        note = build(:compatibility_note_history_entry,
                     text_body: ("a" * 16385))
        expect(note).to be_invalid
        expect(note.errors[:text_body]).to include("is too long (maximum is 16384 characters)")
      end
    end
  end
end
