require 'rails_helper'

RSpec.describe Mod, :model do
  skyui = Mod.find_by(name: 'SkyUI')

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
      compatibility_note = skyui.mod_versions.first.compatibility_notes.create(submitted_by: 3, compatibility_type: "Incompatible")

      it "should increment when we add a compatibility_note" do
        expect(skyui.compatibility_notes_count).to eq(count_before + 1)
      end

      it "should decrement when we remove a compatibility_note" do
        compatibility_note.destroy
        expect(skyui.compatibility_notes_count).to eq(count_before)
      end
    end

  end
end