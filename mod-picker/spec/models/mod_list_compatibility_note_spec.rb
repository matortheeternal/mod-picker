require 'rails_helper'

# create_table "mod_list_compatibility_notes", id: false, force: :cascade do |t|
#   t.integer "mod_list_id",           limit: 4
#   t.integer "compatibility_note_id", limit: 4
#   t.enum    "status",                limit: ["unresolved", "resolved", "ignored"], default: "unresolved"
# end

RSpec.describe ModListCompatibilityNote, :model do
  fixtures :mod_list_compatibility_notes, 
           :compatibility_notes,
           :mod_lists,
           :users

  it "should have a valid factory" do
    expect(build(:mod_list_compatibility_note)).to be_valid
  end

  it "should create a valid note" do
    list = ModListCompatibilityNote.create(
      mod_list_id: mod_lists(:plannedVanilla).id,
      compatibility_note_id: compatibility_notes(:incompatibleNote).id,
      status: "resolved"
      )

    expect(list).to be_valid
    expect(list.mod_list_id).to eq(mod_lists(:plannedVanilla).id)
    expect(list.compatibility_note_id).to eq(compatibility_notes(:incompatibleNote).id)
    expect(list.status).to eq("resolved") 
  end

  # Unsure how to implement a fixture at the moment.
  # TODO: figure out how to implement a fixture for mod_list_compatibility_notes without primary key
  # it "should have a valid fixture" do
  #   mod = mod_lists(:plannedVanilla).mod_list_compatibility_notes.create(
  #     compatibility_note_id: compatibility_notes(:incompatibleNote),
  #     status: "Resolved")

  #   expect(mod).to be_valid
  # end
  
  context "validations" do
    describe "mod_list_id" do
      it "should be invalid if blank" do
        list = build(:mod_list_compatibility_note,
          mod_list_id: nil)

        list.valid?
        expect(list.errors[:mod_list_id]).to include("can't be blank")
      end
    end

    describe "compatibility_note_id" do
      it "should be invalid if blank" do
        list = build(:mod_list_compatibility_note,
          compatibility_note_id: nil)

        list.valid?
        expect(list.errors[:compatibility_note_id]).to include("can't be blank")
      end
    end

    describe "status" do
      it "should default to Unresolved" do
        list = build(:mod_list_compatibility_note)

        expect(list.status).to eq("unresolved")
      end

      it "should only allow valid status enums" do
        list = build(:mod_list_compatibility_note)

        validStatuses = ["unresolved", "resolved", "ignored"]

        validStatuses.each do |status|
          list.status = status

          expect(list).to be_valid
        end
      end

      # Instead of expect(x.errors[:status]).to include("...")
      # Modified to check for argument error instead.
      it "should NOT allow invalid status enums" do
        invalidStatuses = ["Ararargi", "Hatchikuji", "Shinobu", "Ononoki"]

        invalidStatuses.each do |status|
          expect{ build(:mod_list_compatibility_note,
                        status: status)
          }
            .to raise_error(ArgumentError)
            .with_message(/is not a valid status/)
        end
      end

      it "should NOT allow empty/nil status enums" do
        expect{ create(:mod_list_compatibility_note,
                      status: "") }
          .to raise_error(ActiveRecord::StatementInvalid)

      end
    end
  end
end