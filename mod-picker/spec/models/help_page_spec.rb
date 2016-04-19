require 'rails_helper'

# create_table "help_pages", force: :cascade do |t|
#   t.string   "name",      limit: 128,   null: false
#   t.datetime "submitted"
#   t.datetime "edited"
#   t.text     "text_body", limit: 65535
# end

RSpec.describe HelpPage, :model do
  fixtures :help_pages

  it "should have a valid factory" do
    expect(create(:help_page)).to be_valid
  end

  it "should have valid fixtures" do
    expect(help_pages(:help_about_page)).to be_valid
    expect(help_pages(:help_contact_page)).to be_valid
    expect(help_pages(:help_support_page)).to be_valid
  end

  context "validations" do
    describe "name" do
      it "should be invalid if empty" do
        page = build(:help_page,
                name: nil)
        
        page.valid?
        expect(page.errors[:name]).to include("can't be blank") 
      end

      it "should be valid if 4 < Length < 128" do
        page = build(:help_page)

        validLengths = [("a" * 4), ("b" * 128), ("c" * 66), ("d" * 44)]

        validLengths.each do |text|
          page.name = text
          expect(page).to be_valid
        end
      end

      it "should be invalid if length < 4" do
        page = build(:help_page)

        invalidShortLengths = [("a" * 3), ("b" * 1), nil, ""]

        invalidShortLengths.each do |text|
          page.name = text
          expect(page).to be_invalid
          expect(page.errors[:name]).to include("is too short (minimum is 4 characters)")
        end
      end

      it "should be invalid if length > 128" do
        page = build(:help_page,
                     name: ("a" * 129))
        expect(page).to be_invalid
        expect(page.errors[:name]).to include("is too long (maximum is 128 characters)")
      end
    end

    describe "submitted" do
      it "should default to DateTime.now" do
        expect(create(:help_page).submitted)
          .to be_within(1.minute).of DateTime.now  
      end
    end

    describe "text_body" do
      it "should be invalid if empty" do
        page = build(:help_page,
                text_body: nil)
        
        page.valid?
        expect(page.errors[:text_body]).to include("can't be blank") 
      end

      it "should be valid if 64 < Length < 32768" do
        page = build(:help_page)

        validLengths = [("a" * 64), ("b" * 32768), ("c" * 116), ("d" * 15000)]

        validLengths.each do |text|
          page.text_body = text
          expect(page).to be_valid
        end
      end

      it "should be invalid if length < 64" do
        page = build(:help_page)

        invalidShortLengths = [("a" * 3), ("b" * 55), nil, ""]

        invalidShortLengths.each do |text|
          page.text_body = text
          expect(page).to be_invalid
          expect(page.errors[:text_body]).to include("is too short (minimum is 64 characters)")
        end
      end

      it "should be invalid if length > 32768" do
        page = build(:help_page,
                     text_body: ("a" * 32769))
        expect(page).to be_invalid
        expect(page.errors[:text_body]).to include("is too long (maximum is 32768 characters)")
      end
    end
  end
end
