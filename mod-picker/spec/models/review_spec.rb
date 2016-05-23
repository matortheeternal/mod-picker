require 'rails_helper'

RSpec.describe Review, :model do
  fixtures :reviews

  it "should have a valid factory" do
    expect(build(:review)).to be_valid
  end

  it "should have valid fixtures" do
    fixtures_list = [:review_basic, :review_intermediate, :review_advanced]
    fixtures_list.each do |review|
      expect(reviews(review)).to be_valid
    end
  end

  context "counter_caches" do
    let(:review) {reviews(:review_intermediate)}

    # Create an incorrect note through the review fixture and check for increment of 
    # incorrect_notes_count
    # For decrement test, delete the created incorrect note
    describe "incorrect_notes_count" do
      it "should increment the incorrect_notes_count when creating an incorrect note" do
        expect {
          note = review.incorrect_notes.create(attributes_for(:incorrect_note,
          correctable_id: review.id,
          correctable_type: "Review"))

          expect(note).to be_valid
          review.reload

          expect(review.incorrect_notes_count).to eq(1)

        }.to change {review.incorrect_notes_count}.by(1)
      end

      it "should decrement the incorrect_notes_count when deleting an incorrect note" do
        note = review.incorrect_notes.create(attributes_for(:incorrect_note,
          correctable_id: review.id,
          correctable_type: "Review"))

        expect(note).to be_valid
        review.reload

        expect(review.incorrect_notes_count).to eq(1)

        expect {
          review.incorrect_notes.destroy(note.id)
          review.reload
          expect(review.incorrect_notes_count).to eq(0)
        }.to change {review.incorrect_notes_count}.by(-1)
      end
    end
  end
end