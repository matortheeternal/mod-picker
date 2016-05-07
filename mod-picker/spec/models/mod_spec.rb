require 'rails_helper'

# create_table "mods", force: :cascade do |t|
#   t.string  "name",                      limit: 128
#   t.string  "aliases",                   limit: 128
#   t.boolean "is_utility"
#   t.boolean "has_adult_content"
#   t.integer "game_id",                   limit: 4
#   t.integer "primary_category_id",       limit: 4
#   t.integer "secondary_category_id",     limit: 4
#   t.integer "mod_stars_count",           limit: 4,   default: 0
#   t.integer "reviews_count",             limit: 4,   default: 0
#   t.integer "mod_versions_count",        limit: 4,   default: 0
#   t.integer "compatibility_notes_count", limit: 4,   default: 0
#   t.integer "install_order_notes_count", limit: 4,   default: 0
#   t.integer "load_order_notes_count",    limit: 4,   default: 0
# end

RSpec.describe Mod, :model do
  # fixtures
  fixtures :users, :mods

  it "should access the seeded mod" do
    expect(users(:madoka)).to be_truthy
    expect(mods(:SkyUI)).to be_truthy
    expect(mods(:SkyUI).mod_stars_count).to be_truthy
  end

  # noinspection RubyScope
  describe "counter cache" do
    
    # instance variables 
    let(:skyui) { mods(:SkyUI) }
    let(:user) { users(:madoka) }
    let(:tes5edit) { mods(:TES5EDIT) }

    describe "mod_stars_count" do
      let!(:count_before) { skyui.mod_stars_count }

      it "should increment when we add a star" do
        skyui.mod_stars.create(user_id: user.id)
        expect(skyui.mod_stars_count).to eq(count_before + 1)
      end

      it "should decrement when we remove a star" do
        mod_star = skyui.mod_stars.create(user_id: user.id)
        mod_star.destroy
        expect(skyui.mod_stars_count).to eq(count_before)
      end
    end

    describe "reviews_count" do
      let!(:count_before) { skyui.reviews_count }

      it "should increment when we add a review" do
        review = skyui.reviews.create(submitted_by: user.id, rating1: 10)
        expect(skyui.reviews_count).to eq(count_before + 1)
      end

      it "should decrement when we remove a review" do
        review = skyui.reviews.create(submitted_by: user.id, rating1: 10)
        expect(skyui.reviews_count).to eq(count_before + 1)

        review.destroy
        expect(skyui.reviews_count).to eq(count_before)
      end
    end

    describe "mod_versions_count" do
      let!(:count_before) {skyui.mod_versions_count}
      let!(:mod_version) { skyui.mod_versions.create(version: '1.0') }

      it "should increment when we add a mod_version" do
        expect(skyui.mod_versions_count).to eq(count_before + 1)
      end

      it "should decrement when we remove a mod_version" do
        mod_version.destroy
        expect(skyui.mod_versions_count).to eq(count_before)
      end
    end

    describe "compatibility_notes_count" do
      # let!(:count_before) {skyui.compatibility_notes_count}
      # let!(:mod_version1) {skyui.mod_versions.first}
      # let!(:mod_version2) {tes5edit.mod_versions.first}
      # compatibility_note = CompatibilityNote.create!(submitted_by: user.id, compatibility_type: "Incompatible", text_body: Faker::Lorem.paragraphs(3))
      # let(:compatibility_note) { create(:compatibility_note, submitted_by: user.id)}
      # mvcn1 = ModVersionCompatibilityNote.create(mod_version_id: mod_version1.id, compatibility_note_id: compatibility_note.id)
      # mvcn2 = ModVersionCompatibilityNote.create(mod_version_id: mod_version2.id, compatibility_note_id: compatibility_note.id)

      it "should increment when we add a compatibility_note" do
        # expect {
        #   create(:mod_version_compatibility_note,
        #           mod_version_id: )
        # }.to change {skyui.compatibility_notes_count}.by(1)
      end

      # it "should decrement when we remove a compatibility_note" do
      #   mvcn1.destroy
      #   mvcn2.destroy
      #   compatibility_note.destroy
      #   skyui = Mod.find_by(name: 'SkyUI')
      #   expect(skyui.compatibility_notes_count).to eq(count_before)
      # end
    end

    # describe "install_order_notes_count" do
    #   count_before = skyui.install_order_notes_count
    #   mod_version1 = skyui.mod_versions.first
    #   mod_version2 = tes5edit.mod_versions.first
    #   install_order_note = InstallOrderNote.create!(submitted_by: user.id, install_first: skyui.id, install_second: tes5edit.id, text_body: Faker::Lorem.paragraphs(3))
    #   mvin1 = ModVersionInstallOrderNote.create(mod_version_id: mod_version1.id, install_order_note_id: install_order_note.id)
    #   mvin2 = ModVersionInstallOrderNote.create(mod_version_id: mod_version2.id, install_order_note_id: install_order_note.id)

    #   it "should increment when we add an install_order_note" do
    #     skyui = Mod.find_by(name: 'SkyUI')
    #     expect(skyui.install_order_notes_count).to eq(count_before + 1)
    #   end

    #   it "should decrement when we remove an install_order_note" do
    #     mvin1.destroy
    #     mvin2.destroy
    #     install_order_note.destroy
    #     skyui = Mod.find_by(name: 'SkyUI')
    #     expect(skyui.install_order_notes_count).to eq(count_before)
    #   end
    # end

    # describe "load_order_notes_count" do
    #   count_before = skyui.load_order_notes_count
    #   mod_version1 = skyui.mod_versions.first
    #   mod_version2 = tes5edit.mod_versions.first
    #   load_order_note = LoadOrderNote.create!(submitted_by: user.id, load_first: skyui.id, load_second: tes5edit.id, text_body: Faker::Lorem.paragraphs(3))
    #   mvin1 = ModVersionLoadOrderNote.create(mod_version_id: mod_version1.id, load_order_note_id: load_order_note.id)
    #   mvin2 = ModVersionLoadOrderNote.create(mod_version_id: mod_version2.id, load_order_note_id: load_order_note.id)
    
    #   it "should increment when we add an load_order_note" do
    #     skyui = Mod.find_by(name: 'SkyUI')
    #     expect(skyui.load_order_notes_count).to eq(count_before + 1)
    #   end
    
    #   it "should decrement when we remove an load_order_note" do
    #     mvin1.destroy
    #     mvin2.destroy
    #     load_order_note.destroy
    #     skyui = Mod.find_by(name: 'SkyUI')
    #     expect(skyui.load_order_notes_count).to eq(count_before)
    #   end
    # end

  end 
end