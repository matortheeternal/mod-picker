require 'rails_helper'

# create_table "plugins", force: :cascade do |t|
#   t.integer "mod_version_id", limit: 4
#   t.string  "filename",       limit: 64
#   t.string  "author",         limit: 128
#   t.string  "description",    limit: 512
#   t.string  "crc_hash",       limit: 8
# end

# add_index "plugins", ["mod_version_id"], name: "mv_id", using: :btree

RSpec.describe Plugin, :model, :bbb do
  it "should have a valid factory" do
    expect(build(:plugin)).to be_valid
  end


# ==================================================================
# VALIDATIONS
# ==================================================================

  context "validations" do
    describe "mod_version_id" do
      it "should be invalid if blank" do
        plugin = build(:plugin,
          mod_version_id: nil)

        plugin.valid?
        expect(plugin.errors[:mod_version_id]).to include("can't be blank")
      end
    end

    # ==================================================================
    # Filename
    # ==================================================================
    
    describe "filename" do
      it "should be invalid if blank" do
        plugin = build(:plugin,
          filename: nil)

        plugin.valid?
        expect(plugin.errors[:filename]).to include("can't be blank")
      end

      it "should only allow filenames with a length < 64" do
        plugin = build(:plugin)

        validLengths = [("A" * 64), ("a"), ("B" * 33), ("f" * 63)]

        validLengths.each do |filename|
          plugin.filename = filename

          expect(plugin).to be_valid
        end
      end

      it "should be invalid if filenames are blank/have a length of 0" do
        plugin = build(:plugin)

        invalidLengths = [nil, ""]

        invalidLengths.each do |filename|
          plugin.filename = filename

          plugin.valid?
          expect(plugin.errors[:filename]).to include("can't be blank")
        end
      end

      it "should be invalid if filenames have a length > 64" do
        plugin = build(:plugin)

        invalidLengths = [("A" * 65), ("B" * 100), ("f" * 1000)]

        invalidLengths.each do |filename|
          plugin.filename = filename

          expect(plugin).to be_invalid
          expect(plugin.errors[:filename]).to include("is too long (maximum is 64 characters)")
        end
      end
    end

    # ==================================================================
    # Author
    # ==================================================================
    
    describe "author" do
      it "should default to null" do
        plugin = Plugin.new(mod_version_id: 1,
          filename: "homuhomu",
          crc_hash: "abcabcab")
        expect(plugin.author).to be_blank
      end

      it "should only allow authors with a length < 64" do
        plugin = build(:plugin)

        validLengths = [("A" * 64), ("a"), ("B" * 33), ("f" * 63)]

        validLengths.each do |author|
          plugin.author = author

          expect(plugin).to be_valid
        end
      end

      it "should be invalid if author has a length > 64" do
        plugin = build(:plugin)

        invalidLengths = [("A" * 65), ("B" * 100), ("f" * 1000)]

        invalidLengths.each do |author|
          plugin.author = author

          expect(plugin).to be_invalid
          expect(plugin.errors[:author]).to include("is too long (maximum is 64 characters)")
        end
      end

      it "should be valid if author has a length of 0" do
        plugin = build(:plugin,
          author: "")

        expect(plugin).to be_valid
      end
    end

    # ==================================================================
    # Description
    # ==================================================================
    
    describe "description" do
      it "should default to null" do
        plugin = Plugin.new(mod_version_id: 1,
          filename: "homuhomu",
          crc_hash: "abcabcab")
        expect(plugin.description).to be_blank
      end

      it "should only allow description with a length < 512" do
        plugin = build(:plugin)

        validLengths = [("A" * 512), ("a"), ("B" * 234), ("f" * 63)]

        validLengths.each do |description|
          plugin.description = description

          expect(plugin).to be_valid
        end
      end

      it "should be invalid if description has a length > 512" do
        plugin = build(:plugin)

        invalidLengths = [("A" * 513), ("B" * 600), ("f" * 1000)]

        invalidLengths.each do |description|
          plugin.description = description

          expect(plugin).to be_invalid
          expect(plugin.errors[:description]).to include("is too long (maximum is 512 characters)")
        end
      end

      it "should be valid if description has a length of 0" do
        plugin = build(:plugin,
          description: "")

        expect(plugin).to be_valid
      end
    end

    # ==================================================================
    # CRC hash
    # ==================================================================
    
    describe "crc_hash" do
      it "should be invalid if blank" do
        plugin = build(:plugin,
          crc_hash: nil)

        expect(plugin).to be_invalid
        expect(plugin.errors[:crc_hash]).to include("can't be blank")

        plugin.crc_hash = ""
        expect(plugin).to be_invalid
        expect(plugin.errors[:crc_hash]).to include("can't be blank")
      end

      it "should be invalid if length > 8" do
        plugin = build(:plugin)

        invalidLengths = [("a" * 9), ("a" * 20)]

        invalidLengths.each do |hash|
          plugin.crc_hash = hash

          plugin.valid?
          expect(plugin.errors[:crc_hash]).to include("is too long (maximum is 8 characters)")
        end        
      end

      it "should be valid if length within 1..8" do
        plugin = build(:plugin)

        validLengths = [("A" * 8), ("a"), ("B" * 3), ("f" * 5)]

        validLengths.each do |hash|
          plugin.crc_hash = hash

          expect(plugin).to be_valid
        end
      end
    end
  end
end