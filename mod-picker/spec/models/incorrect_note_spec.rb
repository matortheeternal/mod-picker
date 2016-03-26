require 'rails_helper'

describe IncorrectNote do
  it "should be valid with parameters" do
    note = build(:incorrect_note)
    expect(note).to be_valid
  end
end