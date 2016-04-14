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

RSpec.describe ModList, :model do

  fixtures :mod_lists, :users, :mod_versions

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

      it "should be invalid if empty or nil" do
        list = build(:mod_list, has_adult_content: nil)

        list.valid?
        expect(list.errors[:has_adult_content]).to include("must be true or false")
      end
    end

    describe "status" do
      it "should be valid if using valid status enum" do
        valid_types = [:planned, :"under construction", :testing, :complete]

        list = build(:mod_list)

        valid_types.each do |type|
          list.status = type
          expect(list).to be_valid
        end
      end

      # error message is in sql and only partial checking is done
      it "should be invalid if nil" do
        expect{ create(:mod_list, status: nil) }
          .to raise_error(ActiveRecord::StatementInvalid)
          .with_message(/Column 'status' cannot be null/)
      end

      it "should be invalid if no valid status enum is given" do
        invalid_types = [:ring, :ringring, :ringRingRing, :"banana phone"]

        invalid_types.each do |type|
          expect{ build(:mod_list, status: type) }
          .to raise_error(ArgumentError)
          .with_message(/is not a valid status/)
        end
      end
    end

    describe "created" do
      it "should default to DateTime.now" do
        expect( create(:mod_list).created).to be_within(1.minute).of DateTime.now
      end
    end

    describe "description" do
      it "should be valid if 1 < Length < 65535" do
        list = build(:mod_list)

        validLengths = [("a" * 64), ("b" * 65535), ("c" * 20000), ("d" * 3400)]

        validLengths.each do |text|
          list.description = text
          expect(list).to be_valid
        end
      end

      it "should be valid if empty" do
        expect(build(:mod_list, description: nil)).to be_valid
      end

      it "should be invalid if length > 65535" do
        list = build(:mod_list,
                     description: ("a" * 65536))

        list.valid?
        expect(list.errors[:description]).to include("is too long (maximum is 65535 characters)")
      end
    end

    describe "game_id" do
      it "should be invalid if empty" do
        list = build(:mod_list, game_id: nil)

        list.valid?
        expect(list.errors[:game_id]).to include("can't be blank")
      end
    end
  end

  context "counter caches" do
    describe "comments_count" do
      # Basic, resuable modlist fixture
      let!(:list) {mod_lists(:plannedVanilla)}

      it "should increment comment counter by 1 when new comment is made" do
        # c1 = list.comments.create(attributes_for(:comment, submitted_by: users(:madoka).id))
        # expect(c1).to be_valid
        # # puts c1.commentable.comments_count
        # list.reload
        # expect(list.comments_count).to eq(1)

        expect { 
          # attributes_for only provides the attributes for a factory WITHOUT the associations.
          list.comments.create(attributes_for(:comment, submitted_by: users(:madoka).id))
          list.reload
        }.to change { list.comments_count }.by(1)
      end

      it "should decrement the comment counter by 1 if a comment is deleted" do
        comment = list.comments.create(attributes_for(:comment, submitted_by: users(:madoka).id))
        # need to reload between creation/destruction?
        list.reload

        # list.reload
        # expect(list.comments_count).to eq(1)
        # list.comments.destroy(comment.id)
        # list.reload
        # expect(list.comments_count).to eq(0)

        expect {
          list.comments.destroy(comment.id)
          list.reload
        }.to change { list.comments_count }.by(-1)
      end
    end

    describe "plugins_count" do
      # mod list fixture
      let!(:list) {mod_lists(:plannedVanilla)}

      xit "should increment comment counter by 1 when new comment is made" do

        c1 = list.plugins.create(
          attributes_for(:plugin, mod_version_id: mod_versions(:SkyUI_1_0).id))

        # expect(c1).to be_valid
        # list.reload
        # expect(list.plugins_count).to eq(1)

        # expect { 
        #   list.plugins.create(attributes_for(:plugin))
        #   list.reload
        # }.to change { list.comments_count }.by(1)
      end

      xit "should decrement the comment counter by 1 if a comment is deleted" do
        plugin = list.plugins.create(
          attributes_for(:plugin, mod_version_id: mod_versions(:SkyUI_1_0).id))
        list.reload

        expect {
          list.plugins.destroy(plugin.id)
          list.reload
        }.to change { list.plugins_count }.by(-1)
      end
    end
  end
end
