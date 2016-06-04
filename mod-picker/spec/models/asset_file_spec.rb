require 'rails_helper'

# create_table "asset_files", force: :cascade do |t|
#     t.string "filepath", limit: 128, null: false
#   end

#   add_index "asset_files", ["filepath"], name: "filepath", unique: true, using: :btree

# asset_files stores the filepath of an asset

# [6:00] 
# mod_asset_files associates an asset_file record with a mod

# [6:00] 
# it saves memory when multiple mods have the same asset paths and lets us find asset conflicts easier

RSpec.describe AssetFile, :model do
  fixtures :asset_files

  it "should have a valid factory" do
    expect(build(:asset_file)).to be_valid
  end

  # TODO: create fixtures for asset_files
  xit "should have valid fixtures" do
    expect(mod_asset_files(:assetTreeTexture)).to be_valid
    expect(mod_asset_files(:assetRockTexture)).to be_valid
    expect(mod_asset_files(:assetPlantTexture)).to be_valid 
  end

  context "validations" do
    describe "filepath" do
      it "should be invalid if blank" do
        mod = build(:asset_file,
                    filepath: "")
        mod.valid?

        mod2 = build(:asset_file,
                     filepath: nil)

        expect(mod.errors[:filepath]).to include("can't be blank")
        expect(mod.errors[:filepath]).to include("can't be blank")
      end
    end
  end
end