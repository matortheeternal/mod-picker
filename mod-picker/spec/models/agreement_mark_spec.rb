require 'rails_helper'

describe AgreementMark do
  it "should be valid with incorrect_note_id, submitted_by, and agree present" do
    agree = build(:agreement_mark)

    expect(agree).to be_valid
  end

  describe "incorrect_note_id" do
    it "should be invalid without a blank incorrect_note_id field" do
      agree = build(:agreement_mark,
        incorrect_note_id: nil)

      agree.valid?
      expect(agree.errors[:incorrect_note_id]).to include("can't be blank")
    end
  end

  describe "submitted_by" do
    it "should be invalid with a blank submitted_by field" do
        agree = build(:agreement_mark,
          submitted_by: nil)

        agree.valid?
        expect(agree.errors[:submitted_by]).to include("can't be blank")
    end
  end

  describe "agree" do
    it "should be invalid with field of nil" do
        agree = build(:agreement_mark,
          agree: nil)

        agree.valid?
        # FIXME: Create custom validation message for when boolean field is nil/blank
        expect(agree.errors[:agree]).to include("is not included in the list")
    end

    it "should be valid with field of true" do
        agree = build(:agreement_mark,
          agree: true)

        expect(agree).to be_valid
    end

    it "should be valid with a field of false" do
        agree = build(:agreement_mark,
          agree: false)

        expect(agree).to be_valid
    end
  end
end