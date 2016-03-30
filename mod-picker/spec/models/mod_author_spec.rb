require 'rails_helper'

RSpec.describe ModAuthor, :model, :wip do
  it "should have a valid factory" do
    author = build(:mod_author)

    expect(author).to be_valid
  end

  context "fields" do
    describe "mod_id" do
      it "should be invalid if empty" do
        
      end
    end
  end
end