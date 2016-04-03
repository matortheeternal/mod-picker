require 'rails_helper'

  # create_table "install_order_notes", force: :cascade do |t|
  #   t.integer  "submitted_by",   limit: 4,     null: false
  #   t.integer  "install_first",  limit: 4,     null: false
  #   t.integer  "install_second", limit: 4,     null: false
  #   t.datetime "submitted"
  #   t.datetime "edited"
  #   t.text     "text_body",      limit: 65535
  # end

  # add_index "install_order_notes", ["install_first"], name: "fk_rails_bc30c8f58f", using: :btree
  # add_index "install_order_notes", ["install_second"], name: "fk_rails_b74bbcab8b", using: :btree
  # add_index "install_order_notes", ["submitted_by"], name: "fk_rails_ea0bdedfde", using: :btree

RSpec.describe InstallOrderNote, :model do
  fixtures :install_order_notes, 
           :users

  it "should have a valid factory" do
    note = build(:install_order_note)
  end

  it "should have valid fixtures" do
    expect(install_order_notes(:installOrderAlpha)).to be_valid
    expect((install_order_notes(:installOrderBeta))).to be_valid
  end

  context "validations" do
    describe "install_first" do
      it "should be invalid if blank" do
        note = build(:install_order_note,
          install_first: nil)

        note.valid?
        expect(note.errors[:install_first]).to include("can't be blank")
      end
    end

    describe "install_second" do
      it "should be invalid if blank" do
        note = build(:install_order_note,
          install_second: nil)

        note.valid?
        expect(note.errors[:install_second]).to include("can't be blank")
      end
    end

    describe "submitted" do
      it "should be DateTime.now after initialization" do
        note = build(:install_order_note)

        expect(note.submitted).to be_within(1.minute).of DateTime.now
      end
    end

    describe "text_body" do
      it "should be valid with a 64 < length < 16384" do
        note = build(:install_order_note)

        valid_bodies = [("a" * 64), ("a" * 16384), ("a" * 222), ("a" * 10000)]

        valid_bodies.each do |body|
          note.text_body = body

          expect(note).to be_valid
        end
      end

      it "should be invalid if blank/empty" do
        note = build(:install_order_note)

        invalid_bodies = [nil, ""]

        invalid_bodies.each do |body|
          note.text_body = body

          expect(note).to be_invalid
        end
      end
    end
  end
end