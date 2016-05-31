require 'rails_helper'

RSpec.describe CompatibilityNote, :model do
  fixtures :compatibility_notes

  it "should be valid with factory parameters" do
    note = build(:compatibility_note)

    expect(note).to be_valid
  end

  it "should have a valid factory" do
    expect(create(:compatibility_note)).to be_valid
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
        expect{build(:compatibility_note,
          compatibility_type: "Homura")
      }
      .to raise_error(ArgumentError)
      .with_message(/is not a valid compatibility_type/)

    end

    it "should be valid if compatibility_type is included in whitelist of types" do
      note = build(:compatibility_note)

      valid_types = ["incompatible", "partially incompatible", "compatibility mod", 
       "compatibility option", "make custom patch"]

       valid_types.each do |valid_type|
        note.compatibility_type = valid_type
        expect(note).to be_valid
      end
    end

    it "should be invalid if compatibility_type is empty" do

        # TODO: refactor compatibility note spec test for empty enum value
        expect{create(:compatibility_note,
          compatibility_type: nil)}
        .to raise_error(ActiveRecord::StatementInvalid)
      end
    end

    describe "submitted" do
      it "should set the proper date to DateTime.now upon creation" do
        note = create(:compatibility_note)

        expect(note.submitted).to be_within(1.minute).of DateTime.now
      end

      # FIXME: refactor behavior/test for if submitted is empty in compatibility_note
      it "should be valid even if nil due to default init value" do
        note = create(:compatibility_note,
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

  context "counter_caches" do
    describe "corrections_count" do
      # Reusable compatibilitiy note object from fixtures
      let(:note) {compatibility_notes(:incompatibleNote)}

      it "should increment by 1 when creating an correction" do
        expect { 
          inote = note.corrections.create(
            text_body: Faker::Lorem.sentence(20, false, 20),
            correctable_type: "CompatibilityNote",
            correctable_id: note.id)


        }.to change { note.corrections.count }.by(1)
      end

      it "should decrement by 1 when deleting an correction" do
        inote = note.corrections.create(
            text_body: Faker::Lorem.sentence(20, false, 20),
            correctable_type: "CompatibilityNote",
            correctable_id: note.id)

        expect { 
          note.corrections.destroy(inote.id)

        }.to change { note.corrections.count }.by(-1)
      end
    end
  end
end