require 'rails_helper'

RSpec.describe Tag, :model, :cc do
  fixtures :tags, :games, :mods, :mod_lists, :users

  it "should have a valid factory" do
    expect(build(:tag)).to be_valid
  end

  it "should have valid fixtures" do
    valid_list = [:tag_quest, :tag_gameplay, :tag_immersion, :tag_gameplay]

    valid_list.each do |valid_tag|
      expect(tags(valid_tag)).to be_valid
    end
  end

  context "counter_caches" do
      let(:mod) {mods(:Apocalypse)}
      let(:game) {games(:skyrim)}
      let(:tag) {tags(:tag_quest)}
      let(:mod_list) {mod_lists(:plannedVanilla)}
      let(:user) {users(:homura)}
    describe "mods_count" do
      it "should be incremented by one when creating a mod for the tag" do
        expect {
          mod_tag = tag.mod_tags.create(
            tag_id: tag.id,
            mod_id: mod.id)

          expect(mod_tag).to be_valid
          expect(tag.mods_count).to eq(1)
        }.to change {tag.mods_count}.by(1)
      end

      # Note this test only destroys the relationship between the mod and tag
      # Destroying the mod itself will not destroy the relationship(?)
      # FIXME: make mod_tag dependent on mod or tag and destroy if either is destroyed
      it "should decrement by one when destroying a mod for the tag" do
        mod_tag = tag.mod_tags.create(
            tag_id: tag.id,
            mod_id: mod.id)

        expect(mod_tag).to be_valid
        expect(tag.mods_count).to eq(1)

        expect {
          mod.destroy
          tag.reload

          expect(tag.mods_count).to eq(0)
        }.to change {tag.mods_count}.by(-1) 
      end
    end

    describe "mod_lists_count" do
      it "should be incremented by one when creating a mod_list for the tag" do
        expect {
          mod_list_tag = tag.mod_list_tags.create(
            submitted_by: user.id,
            tag_id: tag.id,
            mod_list_id: mod_list.id)

          expect(mod_list_tag).to be_valid
          expect(tag.mod_lists_count).to eq(1)
        }.to change {tag.mod_lists_count}.by(1)
      end
    end
  end
end
