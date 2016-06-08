require 'rails_helper'

RSpec.describe InstallOrderNote, :model do
  fixtures :install_order_notes, 
           :users

  it "should have a valid factory" do
    note = create(:install_order_note,
      submitted: DateTime.now)
    expect(note).to be_valid
  end

  it "should have valid fixtures" do
    expect(install_order_notes(:installOrderAlpha)).to be_valid
    expect((install_order_notes(:installOrderBeta))).to be_valid
  end

  context "validations" do
    describe "first_mod_id" do
      it "should be invalid if blank" do
        note = build(:install_order_note,
          first_mod_id: nil)

        note.valid?
        expect(note.errors[:first_mod_id]).to include("can't be blank")
      end
    end

    describe "second_mod_id" do
      it "should be invalid if blank" do
        note = build(:install_order_note,
          second_mod_id: nil)

        note.valid?
        expect(note.errors[:second_mod_id]).to include("can't be blank")
      end
    end

    describe "submitted" do
      it "should be DateTime.now after initialization" do
        note = create(:install_order_note)

        expect(note.submitted).to be_within(1.minute).of DateTime.now
      end
    end

    # Used fixtures here because these validations don't rely on a newly created object
    describe "text_body" do
      it "should be valid with a 256 < length < 16384" do
        note = install_order_notes(:installOrderAlpha)

        valid_bodies = [("a" * 256), ("a" * 16384), ("a" * 355), ("a" * 10000)]

        valid_bodies.each do |body|
          note.text_body = body

          expect(note).to be_valid
        end
      end

      it "should be invalid with a length < 256" do
        note = install_order_notes(:installOrderAlpha)

        invalid = [("a" * 255), ("a" * 0), ("a" * 100), ("a" * 153)]

        invalid.each do |body|
          note.text_body = body

          expect(note).to_not be_valid
        end
      end

      it "should be invalid with a length > 16384" do
        note = install_order_notes(:installOrderAlpha)

        invalid = [("a" * 16385), ("a" * 16500)]

        invalid.each do |body|
          note.text_body = body

          expect(note).to_not be_valid
        end
      end

      it "should be invalid if blank/empty" do
        note = install_order_notes(:installOrderAlpha)

        invalid_bodies = [nil, ""]

        invalid_bodies.each do |body|
          note.text_body = body

          expect(note).to be_invalid
        end
      end
    end
  end
end