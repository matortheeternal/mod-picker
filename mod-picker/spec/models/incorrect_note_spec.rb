require 'rails_helper'

# create_table "incorrect_notes", force: :cascade do |t|
#   t.integer  "submitted_by",     limit: 4
#   t.text     "text_body",        limit: 65535
#   t.integer  "correctable_id",   limit: 4
#   t.string   "correctable_type", limit: 255
#   t.datetime "created_at"
#   t.datetime "updated_at"
# end


RSpec.describe IncorrectNote, :model do
  it "should be valid with factory parameters" do
    note = build(:incorrect_note)
    expect(note).to be_valid
  end

  context "fields" do
    describe "text_body" do
      it "should be valid with a 64 < length < 16384" do
        note = build(:incorrect_note)

        valid_bodies = [("a" * 64), ("a" * 16384), ("a" * 222), ("a" * 10000)]

        valid_bodies.each do |body|
          note.text_body = body

          expect(note).to be_valid
        end
      end

      it "should be invalid if blank" do
        note = build(:incorrect_note)

        invalid_bodies = [nil, ""]

        invalid_bodies.each do |body|
          note.text_body = body

          expect(note).to be_invalid
        end
      end
    end

    describe "correctable_id" do
      it "should be invalid if blank" do
        note = build(:incorrect_note,
          correctable_id: nil)

        note.valid?
        expect(note.errors[:correctable_id]).to include("can't be blank")
      end
    end

    describe "correctable_type" do
      it "should be invalid if blank" do
        note = build(:incorrect_note,
          correctable_type: nil)

        note.valid?
        expect(note.errors[:correctable_type]).to include("can't be blank")
      end

      it "should be invalid if not a valid correctable_type" do
        note = build(:incorrect_note)

        invalid_types = ["lets", "go", "in", "the", "garden"]

        invalid_types.each do |note_type|
          note.correctable_type = note_type

          expect(note).to be_invalid
          expect(note.errors[:correctable_type]).to include("Not a valid record type that can contain incorrect notes")
        end
      end

      it "should be valid correctable_type is a valid type" do
        note = build(:incorrect_note)

        valid_types = ["CompatibilityNote", "InstallationNote", "Review"]

        valid_types.each do |note_type|
          note.correctable_type = note_type

          expect(note).to be_valid
        end
      end
    end

    describe "created_at" do
      it "should be set to DateTime.now on initilization" do
        note = build(:incorrect_note)

        expect(note).to be_valid
        expect(note.created_at).to be_within(1.minute).of DateTime.now
      end
    end

    # IDEA: validate datetime type for incorrect_note?
    # blank fields are currently valid.
  end
end