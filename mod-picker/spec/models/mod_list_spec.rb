require 'rails_helper'

# create_table "mod_lists", force: :cascade do |t|
#     t.integer  "created_by",                limit: 4
#     t.boolean  "is_collection"
#     t.boolean  "is_public"
#     t.boolean  "has_adult_content"
#     t.integer  "status",                    limit: 1,     default: 0, null: false
#     t.datetime "created"
#     t.datetime "completed"
#     t.text     "description",               limit: 65535
#     t.integer  "game_id",                   limit: 4
#     t.integer  "comments_count",            limit: 4,     default: 0
#     t.integer  "mods_count",                limit: 4,     default: 0
#     t.integer  "plugins_count",             limit: 4,     default: 0
#     t.integer  "custom_plugins_count",      limit: 4,     default: 0
#     t.integer  "compatibility_notes_count", limit: 4,     default: 0
#     t.integer  "install_order_notes_count", limit: 4,     default: 0
#     t.integer  "user_stars_count",          limit: 4,     default: 0
#     t.integer  "load_order_notes_count",    limit: 4,     default: 0
#     t.string   "name",                      limit: 255
#   end

#   add_index "mod_lists", ["created_by"], name: "created_by", using: :btree
#   add_index "mod_lists", ["game_id"], name: "fk_rails_f25cbc0432", using: :btree

RSpec.describe ModList, :model, :wip do

  fixtures :mod_lists

  it "should have a valid factory" do
    expect( create(:mod_list) ).to be_valid
  end

  it "should have a valid fixture" do
    expect(mod_lists(:plannedVanilla)).to be_valid
    expect(mod_lists(:underConstructionVanilla)).to be_valid
  end

  context "validations" do
    describe "is_collection" do
      it "should be valid if true or false" do
        expect(build(:mod_list, is_collection: true)).to be_valid
        expect(build(:mod_list, is_collection: false)).to be_valid
      end

      it "should be invalid if empty or nil" do
        list = build(:mod_list, is_collection: nil)

        list.valid?
        expect(list.errors[:is_collection]).to include("must be true or false")
      end

      it "should default to false" do
        list = create(:mod_list)

        expect(list.is_collection).to eq(false)
      end
    end

    describe "is_public" do
      it "should be valid if true or false" do
        expect(build(:mod_list, is_public: true)).to be_valid
        expect(build(:mod_list, is_public: false)).to be_valid
      end

      it "should be invalid if empty or nil" do
        list = build(:mod_list, is_public: nil)

        list.valid?
        expect(list.errors[:is_public]).to include("must be true or false")
      end

      it "should default to false" do
        list = create(:mod_list)

        expect(list.is_public).to eq(false)
      end
    end

    describe "has_adult_content" do
      it "should be valid if true or false" do
        expect(build(:mod_list, has_adult_content: true)).to be_valid
        expect(build(:mod_list, has_adult_content: true)).to be_valid
      end
    end
  end



end
