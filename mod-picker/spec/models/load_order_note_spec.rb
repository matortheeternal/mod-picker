require 'rails_helper'

# create_table "load_order_notes", force: :cascade do |t|
#     t.integer  "submitted_by", limit: 4,     null: false
#     t.integer  "load_first",   limit: 4,     null: false
#     t.integer  "load_second",  limit: 4,     null: false
#     t.datetime "submitted"
#     t.datetime "edited"
#     t.text     "text_body",    limit: 65535
#   end

#   add_index "load_order_notes", ["load_first"], name: "fk_rails_d6c931c1cc", using: :btree
#   add_index "load_order_notes", ["load_second"], name: "fk_rails_af9e3c9509", using: :btree
#   add_index "load_order_notes", ["submitted_by"], name: "fk_rails_9992d700a9", using: :btree

RSpec.describe LoadOrderNote, :model, :wip do
  fixtures :users

  it "should have a valid factory" do
    expect(build(:load_order_note)).to be_valid
  end

  # TODO: make plugin fixtures
  xit "should create a valid object" do
    note = LoadOrderNote.create(
      submitted_by: users(:homura).id,
      load_first: 1,
      load_second: 2,
      text_body: "Lorem ipsum dolor sit amet, consectetur adipisicing elit. 
                  Nesciunt dolore quos similique voluptatem animi minima iure aperiam, 
                  recusandae soluta laboriosam, itaque nulla facere velit dolor ipsa amet 
                  nemo beatae quibusdam?")

    expect(note).to be_valid
  end

  context "validations" do
    describe "load_first" do
      it "should be invalid if blank" do
        note = build(:load_order_note,
          load_first: nil)

        note.valid?
        expect(note.errors[:load_first]).to include("can't be blank")
      end
    end

    describe "load_second" do
      it "should be invalid if blank" do
        note = build(:load_order_note,
          load_second: nil)

        note.valid?
        expect(note.errors[:load_second]).to include("can't be blank")
      end
    end

    describe "submitted" do
      it "should default to DateTime.now" do
        note = build(:load_order_note)

        expect(note.submitted).to be_within(1.minute).of DateTime.now
      end
    end

    describe "text_body" do
      it "should be valid if 64 < Length < 16384" do
        note = build(:load_order_note)

        validLengths = [("a" * 64), ("b" * 16384), ("c" * 10123), ("d" * 3400)]

        validLengths.each do |text|
          note.text_body = text
          expect(note).to be_valid
        end
      end

      # testing short/nil/blank lengths separate from longer ones to test for individual error messages
      it "should be invalid if length < 64" do
        note = build(:load_order_note)

        invalidShortLengths = [("a" * 63), ("b" * 0), nil]

        invalidShortLengths.each do |text|
          note.text_body = text
          expect(note).to be_invalid
          expect(note.errors[:text_body]).to include("is too short (minimum is 64 characters)")
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