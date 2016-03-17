require 'rails_helper'

describe Comment do
  it "should be valid with parameters" do
    comment = build(:comment)
    expect(comment).to be_valid
  end  
end