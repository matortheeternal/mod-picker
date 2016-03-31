require 'rails_helper'

RSpec.describe ModListCompatibilityNote, :model, :wip do
  it "should have a valid factory" do
    expect(build(:mod_list_compatibility_note)).to be_valid
  end
end