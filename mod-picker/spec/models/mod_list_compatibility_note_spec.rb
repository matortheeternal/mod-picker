require 'rails_helper'

# create_table "mod_list_compatibility_notes", id: false, force: :cascade do |t|
#   t.integer "mod_list_id",           limit: 4
#   t.integer "compatibility_note_id", limit: 4
#   t.enum    "status",                limit: ["Unresolved", "Resolved", "Ignored"], default: "Unresolved"
# end

RSpec.describe ModListCompatibilityNote, :model, :wip do
  fixtures :mod_list_compatibility_notes, 
           :compatibility_notes,
           :mod_lists

  it "should have a valid factory" do
    expect(build(:mod_list_compatibility_note)).to be_valid
  end

  it "should create a valid note" do
    mod = ModListCompatibilityNote.create(
      mod_list_id: mod_lists(:plannedVanilla),
      compatibility_note_id: compatibility_notes(:incompatibleNote),
      status: "Resolved"
      )

    expect(mod).to be_valid
  end

  it "should have a valid fixture" do
    mod = mod_list_compatibility_notes(:resolvedCompNote)

    expect(mod).to be_valid
  end
end