require 'rails_helper'

RSpec.describe ModAuthor, :model, :wip do
  it "should have a valid factory" do
    author = build(:mod_author)

    expect(author).to be_valid
  end

  context "fields" do
    describe "mod_id" do
      it "should be invalid if empty" do
        author = build(:mod_author,
          mod_id: nil) 

        author.valid?
        expect(author.errors[:mod_id]).to include("can't be blank")
      end
    end

    describe "user_id" do
      it "should be invalid if empty" do
        author = build(:mod_author,
          user_id: nil)

        author.valid?
        expect(author.errors[:user_id]).to include("can't be blank")
      end
    end
  end
end