require 'rails_helper'


RSpec.describe ModListCompatibilityNote, :model, :wip do
  fixtures :mod_list_compatibility_notes

  it "should have a valid factory" do
    expect(build(:mod_list_compatibility_note)).to be_valid
  end

  it "should have a valid fixture example" do
    expect(mod_list_compatibility_notes(:resolved)).to be_valid 
  end
end