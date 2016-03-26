require 'rails_helper'

describe Comment do
  it "should be valid with parameters" do
    comment = build(:comment,
      commentable_type: "User")
    puts comment.commentable_type
    expect(comment).to be_valid
  end  

  describe "commentable_type" do
    it "Should be valid with commentable_type [User, ModList]" do 
      comment = build(:comment,
        commentable_type: "User")

      comment2 = build(:comment,
        commentable_type: "ModList")

      expect(comment).to be_valid
      expect(comment2).to be_valid
    end

    it "should invalid with other commentable_type of nil" do
      comment = build(:comment,
        commentable_type: nil)
      expect(comment).to be_invalid
      expect(comment.errors[:commentable_type]).to include("can't be blank")
    end

    it "should invalid with commentable_type not on the valid list of types" do
      comment = build(:comment,
        commentable_type: "Redding")
      expect(comment).to be_invalid
      expect(comment.errors[:commentable_type]).to include("is not included in the list")
    end

    describe "#validate_text_body_length" do
      it "when commentable_type: User, should only be valid with a text_body 1 >= length <= 16384" do
        comment = build(:comment,
          commentable_type: "User",
          text_body: "Hello how are you")
        comment.validate_text_body_length
        expect(comment).to be_valid
      end

      it "when commentable_type: User, should only be invalid with text_body length of 16385" do
        str = "x".times(16385)
        comment = build(:comment,
          commentable_type: "User",
          text_body: str)
        expect(comment).to be_valid
      end

      it "when commentable_type: ModList, should only be valid with a text_body 1 >= length <= 200" do
        comment = build(:comment,
          commentable_type: "ModList",
          text_body: "Hello how are you")
        comment.validate_text_body_length
        expect(comment).to be_valid
      end
    end
  end
end