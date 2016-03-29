require 'rails_helper'

RSpec.describe IncorrectNote, :model do
  it "should be valid with parameters" do
    note = build(:incorrect_note)
    expect(note).to be_valid
  end
end