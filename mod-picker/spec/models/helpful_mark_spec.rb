require 'rails_helper'

RSpec.describe HelpfulMark, :model do
  it "should have a valid factory" do
    mark = build(:helpful_mark)

    expect(mark).to be_valid
  end

  context "fields" do
    describe "helpful" do
      it "should be valid if true or false" do
        mark = build(:helpful_mark)

        valid_states = [true, false]

        valid_states.each do |state|
          mark.helpful = state

          expect(mark).to be_valid 
        end 
      end

      it "should be invalid if nil" do
        mark = build(:helpful_mark,
          helpful: nil)

        mark.valid?
        expect(mark.errors[:helpful]).to include("must be true or false")  
      end
    end

    describe "helpfulable_id" do
      it "should be invalid if nil" do
        mark = build(:helpful_mark,
        helpfulable_id: nil)

        mark.valid?
        expect(mark.errors[:helpfulable_id]).to include("can't be blank")
      end
    end

    describe "helpfulable_type" do
      it "should be valid when given valid types" do
        valid_types = ["CompatibilityNote", "InstallOrderNote", "LoadOrderNote", "Review"]

        mark = build(:helpful_mark)

        valid_types.each do |helpful_type|
          mark.helpfulable_type = helpful_type

          expect(mark).to be_valid
        end
      end

      it "should be invalid if nil" do
        mark = build(:helpful_mark,
          helpfulable_type: nil)

        mark.valid?
        expect(mark.errors[:helpfulable_type]).to include("can't be blank")
      end

      it "should be invalid if not a valid type" do
        mark = build(:helpful_mark,
          helpfulable_type: "Madoka")

        mark.valid?
        expect(mark.errors[:helpfulable_type]).to include("Not a valid record type that can contain helpful marks")
      end      
    end

    describe "submitted" do
      it "should be initialized with DateTime.now" do
        mark = build(:helpful_mark)

        expect(mark).to be_valid
        expect(mark.submitted).to be_within(1.minute).of DateTime.now 
      end
    end
  end
end