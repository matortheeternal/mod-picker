require 'rails_helper'

RSpec.describe Tag, :model, :cc do
  fixtures :tags, :games, :mods

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
    describe "mods_count" do
        let(:mod) {mods(:Apocalypse)}
        let(:game) {games(:skyrim)}
        let(:tag) {tags(:tag_quest)}

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
          mod_tag.destroy
          tag.reload

          expect(tag.mods_count).to eq(0)
        }.to change {tag.mods_count}.by(-1) 
      end
    end
  end
end
