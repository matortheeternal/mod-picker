require 'rails_helper'

# if CREATING comments(and saving to database) comments must be made through its commentable type
# This is because a comment will try to update its commentable's counter_cache upon saving to the database
# and will throw an error if it can't find its commentable.
RSpec.describe Comment, :model do
  # fixtures
  fixtures :users, :mod_lists, :user_bios

  it "should be valid with text_body, commentable_id, and commentable_type submitted parameters" do
    comment = build(:comment,
      commentable_type: "User")
    expect(comment).to be_valid
  end

# ==================================================================
# init method
# ==================================================================
describe "#init" do
  it "should default hidden => false" do
    comment = Comment.create(
                text_body: "Lorem ipsum dolor sit amet, consectetur adipisicing elit. 
                Ex ducimus dolore voluptatem animi error, natus aperiam rerum nisi doloremque, 
                temporibus deserunt dolores molestiae eligendi suscipit numquam ipsam, cumque 
                similique! Asperiores.",
                submitted_by: users(:homura).id,
                commentable_type: "ModList",
                commentable_id: mod_lists(:plannedVanilla).id,
                )

    expect(comment.hidden).to eq(false)
  end

  it "should default submitted => DateTime.now" do
    # submitted is a Date field
    comment = users(:homura).comments.create(attributes_for(:comment))

    expect(comment).to be_valid
    expect(comment.submitted).to be_within(1.minute).of DateTime.now
  end
end

# ==================================================================
# Field validations 
# ==================================================================

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
    expect(comment).to_not be_valid
    expect(comment.errors[:commentable_id]).to include("can't be blank")
  end
end

describe "text_body" do
  it "should be valid if 1 < Length < 8192" do
    comment = build(:comment)

    validLengths = [("a" * 1), ("b" * 8192), ("c" * 4023), ("d" * 234)]

    validLengths.each do |text|
      comment.text_body = text
      expect(comment).to be_valid
    end
  end

  # testing short/nil/blank lengths separate from longer ones to test for individual error messages
  it "should be invalid if length < 1" do
    comment = build(:comment)

    invalidShortLengths = [("b" * 0), nil]

    invalidShortLengths.each do |text|
      comment.text_body = text
      expect(comment).to be_invalid
      expect(comment.errors[:text_body]).to include("is too short (minimum is 1 character)")
    end
  end

  it "should be invalid if length > 16384" do
    comment = build(:comment,
                 text_body: ("a" * 8193))
    expect(comment).to be_invalid
    expect(comment.errors[:text_body]).to include("is too long (maximum is 8192 characters)")
  end
  end


# ==================================================================
# commentable_type field
# ==================================================================

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
    comment = build(:comment)
    comment.commentable_type = nil

    comment.valid?
    expect(comment).to_not be_valid
    expect(comment.errors[:commentable_type]).to include("can't be blank")
  end

  it "should invalid with commentable_type not on the valid list of types" do
    comment = build(:comment)
    comment.commentable_type = nil

    comment.valid?
    expect(comment.errors[:commentable_type]).to include("is not included in the list")
  end

# ==================================================================
# text_body length validations for specific commentable_types
# ==================================================================




  end
end