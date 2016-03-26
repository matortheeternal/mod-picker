require 'rails_helper'

describe Comment do
  it "should be valid with parameters" do
    comment = build(:comment,
      commentable_type: "User")
    expect(comment).to be_valid
  end  

  describe "#init" do
    it "should default hidden => false" do
      comment = build(:comment)
      expect(comment.hidden).to eq(false)
    end

    it "should default submitted => Date.now" do
    # submitted is a Date field
    comment = build(:comment)
    expect(comment.submitted).to be_within(1.minute).of Date.today
  end
end

  describe "submitted_by" do
    it "should be invalid without a user" do
      comment = build(:comment,
        submitted_by: nil)

      comment.valid?
      expect(comment.errors[:submitted_by]).to include("can't be blank")      
    end  
  end

describe "commentable_id" do
    it "should be invalid without an id" do
      comment = build(:comment,
        commentable_id: nil)
      comment.valid?
      expect(comment.errors[:commentable_id]). to include("can't be blank")
    end
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

  it "should invalid with commentable_type of nil" do
    comment = build(:comment,
      commentable_type: nil)
    comment.valid?
    expect(comment.errors[:commentable_type]).to include("can't be blank")
  end

  it "should invalid with commentable_type not on the valid list of types" do
    comment = build(:comment,
      commentable_type: "Redding")
    comment.valid?
    expect(comment.errors[:commentable_type]).to include("is not included in the list")
  end

  describe "#validate_text_body_length" do
    it "with commentable_type: User, should be valid with a text_body 1 <= length  <= 16384" do
      comment = build(:comment,
        commentable_type: "User",
        text_body: "Hello how are you")
      expect(comment).to be_valid
    end

    it "with commentable_type: User, should be valid with a text_body of length 1" do
      comment = build(:comment,
        commentable_type: "User",
        text_body: "a")
      expect(comment).to be_valid
    end

    it "with commentable_type: User, should be invalid with text_body length of  >16384" do
      str = "x" * 16385
      comment = build(:comment,
        commentable_type: "User",
        text_body: str)
      comment.valid?
      expect(comment.errors[:text_body]).to include("length must be less than 16384 characters")
    end      

    it "with commentable_type: User, should be invalid with text_body of nil" do
      comment = build(:comment,
        commentable_type: "User",
        text_body: nil)
      comment.valid?
      expect(comment.errors[:text_body]).to include("body can't be empty")
    end

    it "with commentable_type: ModList, should be valid with a text_body 1 <= length <= 4096" do
      comment = build(:comment,
        commentable_type: "ModList",
        text_body: "Hello how are you")
      comment.valid?
      expect(comment).to be_valid
    end

    it "with commentable_type: ModList, should be valid with a text_body of length 1" do
      comment = build(:comment,
        commentable_type: "ModList",
        text_body: "a")
      comment.valid?
      expect(comment).to be_valid
    end

    it "with commentable_type: ModList, should be invalid with text_body length of >4096" do
      str = "x" * 4097
      comment = build(:comment,
        commentable_type: "ModList",
        text_body: str)
      comment.valid?
      expect(comment.errors[:text_body]).to include("length must be less than 4096 characters")
    end

    it "with commentable_type: ModList, should be invalid with text_body of nil" do
      comment = build(:comment,
        commentable_type: "ModList",
        text_body: nil)
      comment.valid?
      expect(comment.errors[:text_body]).to include("body can't be empty")
    end

  end
end
end