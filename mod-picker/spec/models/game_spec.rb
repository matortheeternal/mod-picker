require 'rails_helper'

RSpec.describe Game, :model do
  fixtures :games

  it "should have a valid fixture" do
    expect(games(:skyrim)).to be_valid
  end
end