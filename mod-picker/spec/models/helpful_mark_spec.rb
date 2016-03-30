require 'rails_helper'

RSpec.describe HelpfulMark, :model, :wip do
  it "should have a valid factory" do
    mark = build(:helpful_mark)

    expect(mark).to be_valid
  end

  context "fields" do
    describe "helpful" do
      it "should only be valid if true or false" do
        
      end
    end
  end
end