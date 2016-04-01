require 'rspec'

RSpec.describe Mod, :model do
  it "should have a valid factory" do
    expect(build(:mod)).to be_valid
    expect(build(:mod_with_versions)).to be_valid
    expect(build(:mod_with_versions).mod_versions.length).to eq(1)
    expect(build(:mod_with_versions, 3).mod_versions.length).to eq(3)
  end

  context counter_cache do

  end
end