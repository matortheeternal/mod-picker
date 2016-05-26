require 'rails_helper'

# create_table "asset_files", force: :cascade do |t|
#     t.string "filepath", limit: 128, null: false
#   end

#   add_index "asset_files", ["filepath"], name: "filepath", unique: true, using: :btree

RSpec.describe AssetFile, :model do
  fixtures :asset_files, :games

  it "should have a valid factory" do
    expect(build(:asset_file)).to be_valid
  end

  it "should have valid fixtures" do
    expect(asset_files(:assetTreeTexture)).to be_valid
    expect(asset_files(:assetRockTexture)).to be_valid
    expect(asset_files(:assetPlantTexture)).to be_valid 
  end

  context "validations" do
    describe "filepath" do
      it "should be invalid if blank" do
        mod = build(:asset_file,
                    filepath: "",
                    game_id: games(:skyrim).id)
        mod.valid?

        mod2 = build(:asset_file,
                     filepath: nil,
                     game_id: games(:skyrim).id)

        expect(mod.errors[:filepath]).to include("can't be blank")
        expect(mod.errors[:filepath]).to include("can't be blank")
      end
    end
  end
end