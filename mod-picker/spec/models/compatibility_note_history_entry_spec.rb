require 'rails_helper'

RSpec.describe CompatibilityNoteHistoryEntry, :model, :wip do
  fixtures :compatibility_note_history_entries

  it "should have a valid fixture" do
    expect(compatibility_note_history_entries(:history_note_apocalypse)).to be_valid
  end
end
