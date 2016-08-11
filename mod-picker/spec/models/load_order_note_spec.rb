require 'rails_helper'

 # create_table "load_order_notes", force: :cascade do |t|
#     t.integer  "game_id",               limit: 4,                     null: false
#     t.integer  "submitted_by",          limit: 4,                     null: false
#     t.integer  "first_plugin_id",       limit: 4,                     null: false
#     t.integer  "second_plugin_id",      limit: 4,                     null: false
#     t.text     "text_body",             limit: 65535,                 null: false
#     t.string   "edit_summary",          limit: 255
#     t.string   "moderator_message",     limit: 255
#     t.integer  "helpful_count",         limit: 4,     default: 0,     null: false
#     t.integer  "not_helpful_count",     limit: 4,     default: 0,     null: false
#     t.integer  "corrections_count",     limit: 4,     default: 0,     null: false
#     t.integer  "history_entries_count", limit: 4,     default: 0,     null: false
#     t.boolean  "approved",                            default: false, null: false
#     t.boolean  "hidden",                              default: false, null: false
#     t.datetime "submitted",                                           null: false
#     t.datetime "edited"
#   end

RSpec.describe LoadOrderNote, :model, :xxx do
  fixtures :users

  it "should have a valid factory" do
    expect(build(:load_order_note)).to be_valid
  end

  # TODO: make plugin fixtures
  xit "should create a valid object" do
    note = LoadOrderNote.create(
      submitted_by: users(:homura).id,
      first_plugin_id: 1,
      second_plugin_id: 2,
      text_body: "a" * 256,)

    expect(note).to be_valid
  end

  context "validations" do
    describe "first_plugin_id" do
      it "should be invalid if blank" do
        note = build(:load_order_note,
          first_plugin_id: nil)

        note.valid?
        expect(note.errors[:first_plugin_id]).to include("can't be blank")
      end
    end

    describe "second_plugin_id" do
      it "should be invalid if blank" do
        note = build(:load_order_note,
          second_plugin_id: nil)

        note.valid?
        expect(note.errors[:second_plugin_id]).to include("can't be blank")
      end
    end

    describe "submitted" do
      it "should default to DateTime.now" do
        note = create(:load_order_note)

        expect(note.submitted).to be_within(1.minute).of DateTime.now
      end
    end

    describe "text_body" do
      it "should be valid if 256 < Length < 16384" do
        note = build(:load_order_note)

        validLengths = [("a" * 256), ("b" * 16384), ("c" * 10123), ("d" * 3400)]

        validLengths.each do |text|
          note.text_body = text
          expect(note).to be_valid
        end
      end

      # testing short/nil/blank lengths separate from longer ones to test for individual error messages
      it "should be invalid if length < 256" do
        note = build(:load_order_note)

        invalidShortLengths = [("a" * 63), ("b" * 0), nil]

        invalidShortLengths.each do |text|
          note.text_body = text
          expect(note).to be_invalid
          expect(note.errors[:text_body]).to include("is too short (minimum is 256 characters)")
        end
      end

      it "should be invalid if length > 16384" do
        note = build(:load_order_note,
                     text_body: ("a" * 16385))
        expect(note).to be_invalid
        expect(note.errors[:text_body]).to include("is too long (maximum is 16384 characters)")
      end
    end
  end


end