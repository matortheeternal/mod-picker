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
  fixtures :users, :mods, :review_templates, :mod_versions,
    :plugins

  it "should have valid fixtures" do
    expect(users(:madoka)).to be_truthy
    expect(mods(:SkyUI)).to be_truthy
    expect(mods(:SkyUI).mod_stars_count).to be_truthy
  end

  it "should have a valid factory" do
    expect(build(:mod)).to be_valid
  end

  # noinspection RubyScope
  context "counter cache" do
    
    # instance variables 
    let(:skyui) { mods(:SkyUI) }
    let(:user) { users(:madoka) }
    let(:mod) { mods(:TES5Edit) }
    let(:mod_version) {mod_versions(:SkyUI_1_0)}

    describe "mod_stars_count" do
      # create a mod star using a mod fixture as a base and a user fixture as the user
      it "should increment when we add a star" do
        expect { 
          mod.mod_stars.create(user_id: user.id)
        }.to change { mod.mod_stars_count }.by(1)
      end

      # create a mod_star then destroy the same one later while keeping track of the mod's mod_stars_count
      it "should decrement when we remove a star" do
        star = mod.mod_stars.create(user_id: user.id)
        expect(mod.mod_stars_count).to eq(1)

        expect {
          mod.mod_stars.destroy(star.id)
          expect(mod.mod_stars_count).to eq(0)
        }.to change { mod.mod_stars_count }.by(-1)
      end
    end

    describe "reviews_count" do
      # Should create a review and confirm the reviews_count is increased by 1
      it "should increment when we add a review" do
        expect {
          review = mod.reviews.create(attributes_for(:review,
            submitted_by: user.id,
            review_template_id: review_templates(:r_template_basic).id))

          expect(mod.reviews_count).to eq(1)
        }.to change { mod.reviews_count }.by(1)
      end

      # Should create a review, then destroy it. changing the reviews_count to 1 then back to 0
      it "should decrement when we remove a review" do
        review = mod.reviews.create(attributes_for(:review,
            submitted_by: user.id,
            review_template_id: review_templates(:r_template_basic).id))

        expect(mod.reviews_count).to eq(1)

        expect {
          mod.reviews.destroy(review.id)
          expect(mod.reviews_count).to eq(0)
        }.to change {mod.reviews_count}.by(-1)
      end
    end

    describe "mod_versions_count" do

      # Creates a mod_version and expects mod_versions_count to increment by 1
      it "should increment when we add a mod_version" do
        # expect(skyui.mod_versions_count).to eq(count_before + 1)

        expect {
          mod.mod_versions.create(attributes_for(:mod_version))
          expect(mod.mod_versions_count).to eq(1)
        }.to change { mod.mod_versions_count }.by(1)
      end

      # Creates a mod_version and expects mod_versions_count to increment by 1 then decrement by 1
      # once the mod_version is destroyed
      it "should decrement when we remove a mod_version" do
          m_version = mod.mod_versions.create(attributes_for(:mod_version))
          expect(mod.mod_versions_count).to eq(1)

        expect {
          mod.mod_versions.destroy(m_version.id)
          expect(mod.mod_versions_count).to eq(0)
        }.to change { mod.mod_versions_count }.by(-1)
      end
    end

    describe "compatibility_notes_count" do

      # Association mod_version fixture with mod_fixture(Maybe associate them in the fixtures themselves)
      # create a compatibility note,
      # then create an association between the compatibility note and mod_version
      # check for increment in mod's compatibility_notes_count
      it "should increment when we add a compatibility_note" do
        # Associates mod_version with mod
        mod_version.mod_id = mod.id
        mod_version.save

        comp_note = create(:compatibility_note,
            submitted_by: user.id)
        expect(comp_note).to be_valid

        expect {
          mod_version.mod_version_compatibility_notes.create(
            compatibility_note_id: comp_note.id)
          mod.reload

          expect(mod.compatibility_notes_count).to eq(1)
        }.to change {mod.compatibility_notes_count}.by(1)
      end

      # same as above process for incrementing a compatibility_note_count but then delete the association.
      it "should decrement when we remove a compatibility_note" do
        # associate mod with mod_version
        mod_version.mod_id = mod.id
        mod_version.save

        # Create compatibility note
        comp_note = create(:compatibility_note,
            submitted_by: user.id)
        expect(comp_note).to be_valid

        # create association between mod_version and compatibility note created above
        mv_cn = mod_version.mod_version_compatibility_notes.create(
            compatibility_note_id: comp_note.id)
        mod.reload
        expect(mod.compatibility_notes_count).to eq(1)

        # destroy association(and compatibility_note) to see counter decrement
        expect {
          mv_cn.destroy
          comp_note.destroy
          mod.reload

          expect(mod.compatibility_notes_count).to eq(0)
        }.to change {mod.compatibility_notes_count}.by(-1)
      end
    end

    describe "install_order_notes_count" do
      it "should increment when we add an install_order_note" do
        mod_version.mod_id = mod.id
        mod_version.save

        install_note = create(:install_order_note,
          submitted_by: user.id,
          install_first: mod.id,
          install_second: mods(:Apocalypse).id)

        expect(install_note).to be_valid

        expect {
          mod_version.mod_version_install_order_notes.create(
            install_order_note_id: install_note.id)
          mod.reload

          expect(mod.install_order_notes_count).to eq(1)
        }.to change {mod.install_order_notes_count}.by(1)
      end

      it "should decrement when we remove an install_order_note" do
        mod_version.mod_id = mod.id
        mod_version.save

        install_note = create(:install_order_note,
          submitted_by: user.id,
          install_first: mod.id,
          install_second: mods(:Apocalypse).id)

        expect(install_note).to be_valid

        mv_in = mod_version.mod_version_install_order_notes.create(
            install_order_note_id: install_note.id)
        mod.reload

        expect(mod.install_order_notes_count).to eq(1)
          
        expect {
          mv_in.destroy
          install_note.destroy
          mod.reload

          expect(mod.install_order_notes_count).to eq(0)

        }.to change {mod.install_order_notes_count}.by(-1)
      end
    end

    describe "load_order_notes_count" do
      it "should increment when we add an load_order_note" do
        mod_version.mod_id = mod.id
        mod_version.save

        load_order_note = create(:load_order_note,
          submitted_by: user.id,
          load_first: plugins(:Apocalypse_esp).id,
          load_second: plugins(:SkyRE_esp).id)

        expect(load_order_note).to be_valid

        expect {
          mod_version.mod_version_load_order_notes.create(
            load_order_note_id: load_order_note.id)
          mod.reload

          expect(mod.load_order_notes_count).to eq(1)
        }.to change {mod.load_order_notes_count}.by(1)
      end
    
      it "should decrement when we remove an load_order_note" do
        mod_version.mod_id = mod.id
        mod_version.save

        load_order_note = create(:load_order_note,
          submitted_by: user.id,
          load_first: plugins(:Apocalypse_esp).id,
          load_second: plugins(:SkyRE_esp).id)

        expect(load_order_note).to be_valid

        mv_lo = mod_version.mod_version_load_order_notes.create(
            load_order_note_id: load_order_note.id)
        mod.reload

        expect(mod.load_order_notes_count).to eq(1)

        expect {
          mv_lo.destroy
          load_order_note.destroy
          mod.reload

          expect(mod.load_order_notes_count).to eq(0)
        }.to change {mod.load_order_notes_count}.by(-1)
      end
    end

  end 
end