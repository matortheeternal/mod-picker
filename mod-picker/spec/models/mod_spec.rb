require 'rails_helper'

RSpec.describe Mod, :model do
  skyui = Mod.find_by(name: 'SkyUI')
  tes5edit = Mod.find_by(name: 'TES5Edit')

  it "should access the seeded mod" do
    expect(skyui).to be_truthy
    expect(skyui.name).to eq('SkyUI')
  end

  describe "counter cache" do
    describe "mod_stars_count" do
      count_before = skyui.mod_stars_count
      mod_star = skyui.mod_stars.create(user_id: 3)

      it "should increment when we add a star" do
        expect(skyui.mod_stars_count).to eq(count_before + 1)
      end

      it "should decrement when we remove a star" do
        mod_star.destroy
        expect(skyui.mod_stars_count).to eq(count_before)
      end
    end

    describe "reviews_count" do
      count_before = skyui.reviews_count
      review = skyui.reviews.create(submitted_by: 3, rating1: 10)

      it "should increment when we add a review" do
        expect(skyui.reviews_count).to eq(count_before + 1)
      end

      it "should decrement when we remove a review" do
        review.destroy
        expect(skyui.reviews_count).to eq(count_before)
      end
    end

    describe "mod_versions_count" do
      count_before = skyui.mod_versions_count
      mod_version = skyui.mod_versions.create(version: '1.0')

      it "should increment when we add a mod_version" do
        expect(skyui.mod_versions_count).to eq(count_before + 1)
      end

      it "should decrement when we remove a mod_version" do
        mod_version.destroy
        expect(skyui.mod_versions_count).to eq(count_before)
      end
    end

    describe "compatibility_notes_count" do
      count_before = skyui.compatibility_notes_count
      mod_version1 = skyui.mod_versions.first
      mod_version2 = tes5edit.mod_versions.first
      compatibility_note = CompatibilityNote.create!(submitted_by: 3, compatibility_type: "Incompatible", text_body: Faker::Lorem.paragraphs(3))
      mvcn1 = ModVersionCompatibilityNote.create(mod_version_id: mod_version1.id, compatibility_note_id: compatibility_note.id)
      mvcn2 = ModVersionCompatibilityNote.create(mod_version_id: mod_version2.id, compatibility_note_id: compatibility_note.id)

      it "should increment when we add a compatibility_note" do
        skyui = Mod.find_by(name: 'SkyUI')
        expect(skyui.compatibility_notes_count).to eq(count_before + 1)
      end

      it "should decrement when we remove a compatibility_note" do
        mvcn1.destroy
        mvcn2.destroy
        compatibility_note.destroy
        skyui = Mod.find_by(name: 'SkyUI')
        expect(skyui.compatibility_notes_count).to eq(count_before)
      end
    end

    describe "install_order_notes_count" do
      count_before = skyui.install_order_notes_count
      mod_version1 = skyui.mod_versions.first
      mod_version2 = tes5edit.mod_versions.first
      install_order_note = InstallOrderNote.create!(submitted_by: 3, install_first: skyui.id, install_second: tes5edit.id, text_body: Faker::Lorem.paragraphs(3))
      mvin1 = ModVersionInstallOrderNote.create(mod_version_id: mod_version1.id, install_order_note_id: install_order_note.id)
      mvin2 = ModVersionInstallOrderNote.create(mod_version_id: mod_version2.id, install_order_note_id: install_order_note.id)

      it "should increment when we add an install_order_note" do
        skyui = Mod.find_by(name: 'SkyUI')
        expect(skyui.install_order_notes_count).to eq(count_before + 1)
      end

      it "should decrement when we remove an install_order_note" do
        mvin1.destroy
        mvin2.destroy
        install_order_note.destroy
        skyui = Mod.find_by(name: 'SkyUI')
        expect(skyui.install_order_notes_count).to eq(count_before)
      end
    end
  end
end