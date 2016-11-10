require 'rails_helper'

RSpec.describe AgreementMark, :model do
  it "should be valid with factory parameters" do
    agree = build(:agreement_mark)
    
    expect(agree).to be_valid
  end

  describe "correction_id" do
    it "should be invalid without a blank correction_id field" do
      agree = build(:agreement_mark,
        correction_id: nil)

      agree.valid?
      expect(agree.errors[:correction_id]).to include("can't be blank")
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