require 'rails_helper'

RSpec.describe Mod, :model do
  it "should have a valid factory" do
    expect(build(:mod)).to be_valid
    expect(build(:mod_with_versions)).to be_valid
  end

  it "should have a valid mod versions factory" do
    expect(build(:mod_with_versions).mod_versions.length).to eq(1)
    expect(build(:mod_with_versions, 3).mod_versions.length).to eq(3)
  end
end