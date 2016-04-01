require 'rails_helper'

# create_table "mod_asset_files", force: :cascade do |t|
#     t.string "filepath", limit: 128, null: false
#   end

#   add_index "mod_asset_files", ["filepath"], name: "filepath", unique: true, using: :btree

RSpec.describe ModAssetFile, :model, :wip do
  it "should have a valid factory" do
    expect(build(:mod_asset_file)).to be_valid
  end

  context "validations" do
    describe "filepath" do
      it "should be invalid if blank" do
        mod = build(:mod_asset_file,
                    filepath: "")
        mod.valid?

        mod2 = build(:mod_asset_file,
                     filepath: nil)

        expect(mod.errors[:filepath]).to include("can't be blank")
        expect(mod.errors[:filepath]).to include("can't be blank")
      end
    end
  end
end