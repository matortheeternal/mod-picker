require 'rails_helper'

RSpec.describe CompatibilityNote, :model, :wip do
  fixtures :compatibility_notes

  it "should be valid with factory parameters" do
    note = build(:compatibility_note)

    expect(note).to be_valid
  end

  it "should have a valid fixture" do
    expect(compatibility_notes(:incompatibleNote)).to be_valid
    expect(compatibility_notes(:compatibilityPluginNote)).to be_valid
  end

# ==================================================================
# Table Fields
# ==================================================================

context "validations" do
  describe "submitted_by" do
    it "should be invalid if submitted_by is nil" do
      note = build(:compatibility_note,
        submitted_by: nil)
      note.valid?
      expect(note.errors[:submitted_by]).to include("can't be blank")
    end
  end


  xdescribe "compatibility_mod_id" do
  end

  xdescribe "compatibility_plugin_id" do
  end

  describe "compatibility_type" do
    it "should be invalid if not included within valid list of types" do
      note = build(:compatibility_note,
        compatibility_type: "Homura")

      note.valid?
      expect(note.errors[:compatibility_type]).to include("Not a valid compatibility type")
    end

    it "should be valid if compatibility_type is included in whitelist of types" do
      note = build(:compatibility_note,
        compatibility_type: "Make Custom Patch")

      valid_types = ["Incompatible", "Partially Incompatible", "Compatibility Mod",
                     "Compatibility Plugin", "Make Custom Patch"]

      valid_types.each do |valid_type|
        note.compatibility_type = valid_type
        expect(note).to be_valid
      end
    end
  end

  describe "submitted" do
    it "should set the proper date to DateTime.now upon creation" do
      note = create(:compatibility_note)

      expect(note.submitted).to be_within(1.minute).of DateTime.now
    end

    it "should be valid even if nil due to default init value" do
      note = build(:compatibility_note,
        submitted: nil)

      note.valid?
      expect(note).to be_valid
    end
  end


  # TODO: add tests for compatibility notes edited field
  #  xdescribe "edited" do
  #   it "should be valid under x circumstances" do
  #   end

  #   it "should be invalid under y circumstances" do
  #   end
  # end

 describe "text_body" do
  it "should be valid with 64 < Length < 16384" do
    minText = "a" * 64
    maxText = "a" * 16384

    minNote = build(:compatibility_note,
      text_body: minText)

    maxNote = build(:compatibility_note,
      text_body: maxText)

    expect(minNote).to be_valid
    expect(maxNote).to be_valid
  end

  it "should be invalid with a length < 64" do
    invalidText = "a" * 63
    note = build(:compatibility_note,
      text_body: invalidText)

    note.valid?
    expect(note.errors[:text_body]).to include("is too short (minimum is 64 characters)")
  end

  it "should be invalid with a length of > 16384" do
    invalidText = "a" * 16385
    note = build(:compatibility_note,
      text_body: invalidText)

    note.valid?
    expect(note.errors[:text_body]).to include("is too long (maximum is 16384 characters)")
  end

  it "should be invalid with an empty body" do
    note = build(:compatibility_note,
      text_body: "")

    note2 = build(:compatibility_note,
      text_body: nil)

    note.valid?
    note2.valid?

    expect(note.errors[:text_body]).to include("is too short (minimum is 64 characters)")
    expect(note2.errors[:text_body]).to include("is too short (minimum is 64 characters)")
  end
end
end
end