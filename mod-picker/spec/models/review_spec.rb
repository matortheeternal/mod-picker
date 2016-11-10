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

    # Create a correction through the review fixture and check for increment of
    # corrections_count
    # For decrement test, delete the created correction
    describe "corrections_count" do
      it "should increment the corrections_count when creating a correction" do
        expect {
          note = review.corrections.create(attributes_for(:correction,
          correctable_id: review.id,
          correctable_type: "Review"))

          expect(note).to be_valid
          review.reload

          expect(review.corrections_count).to eq(1)

        }.to change {review.corrections_count}.by(1)
      end

      it "should decrement the corrections_count when deleting a correction" do
        note = review.corrections.create(attributes_for(:correction,
          correctable_id: review.id,
          correctable_type: "Review"))

        expect(note).to be_valid
        review.reload

        expect(review.corrections_count).to eq(1)

        expect {
          review.corrections.destroy(note.id)
          review.reload
          expect(review.corrections_count).to eq(0)
        }.to change {review.corrections_count}.by(-1)
      end
    end
  end
end