require 'rails_helper'

# create_table "mod_lists", force: :cascade do |t|
#     t.integer  "created_by",                limit: 4
#     t.boolean  "is_collection"
#     t.boolean  "hidden"
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

  fixtures :mod_lists, :users, :mod_versions, :games, :categories, :mods,
    :plugins

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

    describe "hidden" do
      it "should be valid if true or false" do
        expect(build(:mod_list, hidden: true)).to be_valid
        expect(build(:mod_list, hidden: false)).to be_valid
      end

      it "should be invalid if empty or nil" do
        list = build(:mod_list, hidden: nil)

        list.valid?
        expect(list.errors[:hidden]).to include("must be true or false")
      end

      it "should default to true" do
        list = create(:mod_list)

        expect(list.hidden).to eq(true)
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
        # Basic working example without the expect proc
        # c1 = list.comments.create(attributes_for(:comment, submitted_by: users(:madoka).id))
        # expect(c1).to be_valid
        # # puts c1.commentable.comments_count
        # list.reload
        # expect(list.comments_count).to eq(1)

        expect { 
          # attributes_for only provides the attributes for a factory WITHOUT the associations.
          list.comments.create(attributes_for(:comment, 
            submitted_by: users(:madoka).id))

          list.reload
        }.to change { list.comments_count }.by(1)
      end

      it "should decrement the comment counter by 1 if a comment is deleted" do
        comment = list.comments.create(attributes_for(:comment, 
          submitted_by: users(:madoka).id))

        # need to reload between creation/destruction
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

    # TODO: refactor tests in mod_list_Spec to use the other method below
    describe "plugins_count" do
      let!(:list) {mod_lists(:plannedVanilla)}

      it "should increment plugin counter by 1 when new plugin is made" do
        expect(list.plugins_count).to eq(0)

        expect{
          plugin = create(:plugin,
            mod_version_id: mod_versions(:SkyUI_1_0).id)

          expect(plugin).to be_valid

          list.mod_list_plugins.create(
            mod_list_id: list.id,
            plugin_id: plugin.id,
            index: 1)


          expect(list.plugins_count).to eq(1)
        }.to change { list.plugins_count}.by(1)
      end

      it "should decrement the plugin counter by 1 if a plugin is deleted" do
        plugin = create(:plugin,
            mod_version_id: mod_versions(:SkyUI_1_0).id)

        plugin_list = list.mod_list_plugins.create(
            mod_list_id: list.id,
            plugin_id: plugin.id,
            index: 1)

        expect(list.plugins_count).to eq(1)

        expect{
          list.plugins.destroy(plugin.id)

          expect(list.plugins_count).to eq(0)
        }.to change { list.plugins_count}.by(-1)
      end
    end

    describe "mods_count" do
      let!(:list) {mod_lists(:plannedVanilla)}

      it "should increment mods counter by 1 when new mod is made" do
        # expect(list.mods_count).to eq(0)

        # expect { 
        #   list.mods.create(attributes_for(:mod, 
        #       game_id: games(:skyrim).id, primary_category_id: categories(:catGameplay).id))

        #   list.reload
        #   expect(list.mods_count).to eq(1)
        # }.to change { list.mods_count }.by(1)

        expect(list.mods_count).to eq(0)

        expect{
          mod = create(:mod,
          game_id: games(:skyrim).id, 
          primary_category_id: categories(:catGameplay).id)

          mod_list = list.mod_list_mods.create(
            mod_list_id: list.id,
            mod_id: mod.id,
            index: 1)

          expect(list.mods_count).to eq(1)
        }.to change { list.mods_count}.by(1)


      end

      it "should decrement the mods counter by 1 if a mod is deleted" do
        mod = create(:mod,
          game_id: games(:skyrim).id, 
          primary_category_id: categories(:catGameplay).id)

        mod_list = list.mod_list_mods.create(
            mod_list_id: list.id,
            mod_id: mod.id,
            index: 1)

        expect(list.mods_count).to eq(1)

        expect{
          list.mods.destroy(mod.id)

          expect(list.mods_count).to eq(0)
        }.to change { list.mods_count}.by(-1)
      end
    end

    describe "custom_plugins_count" do
      let!(:list) {mod_lists(:plannedVanilla)}

      it "should increment custom_plugins counter by 1 when new custom plugin is made" do
        expect(list.custom_plugins_count).to eq(0)

        expect {
          list.custom_plugins.create(attributes_for(:mod_list_custom_plugin, 
            mod_list_id: list.id))

          list.reload
          expect(list.custom_plugins_count).to eq(1)
        }.to change { list.custom_plugins_count }.by(1)
      end

      it "should decrement the custom_plugins counter by 1 if a custom plugin is deleted" do
        custom = list.custom_plugins.create(attributes_for(:mod_list_custom_plugin, 
          mod_list_id: list.id))

        expect {
          list.custom_plugins.destroy(custom.id)
          list.reload
        }.to change { list.custom_plugins_count }.by(-1)
      end
    end

    describe "compatibility_notes_count" do
      let!(:list) {mod_lists(:plannedVanilla)}

      it "should increment compatibility_notes counter by 1 when new compatibility note is made" do
        expect(list.compatibility_notes_count).to eq(0)

        # This implementation allows validation of BOTH mod_list_id and compatibility_note_id on
        # the mod_list_compatibility_notes model.
        # Unsure if the intended behavior is to invalidate creations of compatibiltiy notes
        # through the mod_list though.
        expect{
          note = create(:compatibility_note)

          comp = list.mod_list_compatibility_notes.create(
            mod_list_id: list.id, 
            compatibility_note_id: note.id)

          expect(comp).to be_valid

          # puts "ID NUMBERS==="

          # puts list.mod_list_compatibility_notes.last.compatibility_note_id # Equal V
          # puts note.mod_list_compatibility_notes.last.compatibility_note_id #   Equal |
          # puts note.id                                                      #   Equal ^
          # puts "==========="
          # puts list.id                                          # Equal V
          # puts note.mod_list_compatibility_notes.last.mod_list_id # Equal ^

          expect(list.compatibility_notes_count).to eq(1)
        }.to change { list.compatibility_notes_count}.by(1)
      end

      it "should decrement the compatibility_notes counter by 1 if a compatibility note is deleted" do
        note = create(:compatibility_note)

        comp_note = list.mod_list_compatibility_notes.create(
          mod_list_id: list.id, 
          compatibility_note_id: note.id)

        expect(list.compatibility_notes_count).to eq(1)

        expect{
          list.compatibility_notes.destroy(note.id)

          expect(list.compatibility_notes_count).to eq(0)
        }.to change { list.compatibility_notes_count}.by(-1)
      end
    end

    describe "install_order_notes_count" do
      let!(:list) {mod_lists(:plannedVanilla)}

      it "should increment install_order_notes counter by 1 when new install order note is made" do
        expect(list.install_order_notes_count).to eq(0)

        expect{
          note = create(:install_order_note,
            submitted_by: users(:homura).id,
            install_first: mods(:Apocalypse).id,
            install_second: mods(:SkyRE).id)

          expect(note).to be_valid

          list.mod_list_install_order_notes.create(
            mod_list_id: list.id,
            install_order_note_id: note.id)

          expect(list.install_order_notes_count).to eq(1)
        }.to change { list.install_order_notes_count}.by(1)
      end

      it "should decrement the install_order_notes counter by 1 if a install order note is deleted" do
        note = create(:install_order_note, 
          submitted_by: users(:homura).id,
          install_first: mods(:Apocalypse).id,
          install_second: mods(:SkyRE).id)

        install_note = list.mod_list_install_order_notes.create(
          mod_list_id: list.id, 
          install_order_note_id: note.id)

        expect(list.install_order_notes_count).to eq(1)

        expect{
          list.install_order_notes.destroy(note.id)

          expect(list.install_order_notes_count).to eq(0)
        }.to change { list.install_order_notes_count}.by(-1)
      end
    end

    describe "user_stars_count" do
      let!(:list) {mod_lists(:plannedVanilla)}

      it "should increment user_stars counter by 1 when new user star is made" do
        expect(list.user_stars_count).to eq(0)

        expect{
          user = users(:homura)

          mod_star =list.mod_list_stars.create(
            mod_list_id: list.id,
            user_id: user.id)

          expect(mod_star).to be_valid

          expect(list.user_stars_count).to eq(1)
        }.to change { list.user_stars_count}.by(1)
      end

      it "should decrement the user_stars counter by 1 if a user star is deleted" do
        user = users(:homura)

        mod_star =list.mod_list_stars.create(
          mod_list_id: list.id,
          user_id: user.id)
          
        expect(mod_star).to be_valid
        expect(list.user_stars_count).to eq(1)

        expect{
          list.mod_list_stars.destroy(mod_star.id)

          expect(list.user_stars_count).to eq(0)
        }.to change { list.user_stars_count}.by(-1)
      end
    end

    describe "load_order_notes_count" do
      let!(:list) {mod_lists(:plannedVanilla)}

      it "should increment load_order_notes counter by 1 when new load order note is made" do
        expect(list.load_order_notes_count).to eq(0)

        expect{
          note = create(:load_order_note,
            load_first: plugins(:Apocalypse_esp).id,
            load_second: plugins(:SkyRE_esp).id,
            submitted_by: users(:homura).id)

          mod_list_note = list.mod_list_load_order_notes.create(
            mod_list_id: list.id,
            load_order_note_id: note.id)

          expect(list.load_order_notes_count).to eq(1)
        }.to change { list.load_order_notes_count}.by(1)
      end

      it "should decrement the load_order_notes counter by 1 if a load order note is deleted" do
        note = create(:load_order_note, 
          submitted_by: users(:homura).id,
          load_first: plugins(:Apocalypse_esp).id,
          load_second: plugins(:SkyRE_esp).id)

        install_note = list.mod_list_load_order_notes.create(
          mod_list_id: list.id, 
          load_order_note_id: note.id)

        expect(list.load_order_notes_count).to eq(1)

        expect{
          list.load_order_notes.destroy(note.id)

          expect(list.load_order_notes_count).to eq(0)
        }.to change { list.load_order_notes_count}.by(-1)
      end
    end
  end
end
