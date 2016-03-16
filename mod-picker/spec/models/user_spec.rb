# This file and all spec fils should mirror the app directory.
# for instance, this user_spec spec should have a user file in the app/models
# directory for the actual model.
require 'rails_helper'

describe User do
  it "is valid with a username, email, and password" do
    user = build(:user)
    expect(user).to be_valid
  end

  it "is invalid without a username" do
    user = User.new(
      username: nil,
      )
    user.valid?
    expect(user.errors[:username]).to include("can't be blank");
  end

  it "is invalid without an email" do
    user = User.new(
      email: nil,
    )
    user.valid?
    expect(user.errors[:email]).to include("can't be blank")
  end

  it "is invalid with a duplicate email address" do
    User.create(
      username: "Shinobu",
      email: "kissshot@mail.com",
      password: "Thepaswordisnil"
    )

    user = User.new(
      username: "Hatchikuji",
      email: "kissshot@mail.com",
      password: "thiscanbewhatever"
    )

    user.valid?
    expect(user.errors[:email]).to include("has already been taken")
  end

  it "is invalid with a duplicate username" do
    User.create(
      username: "Shinobu",
      email: "kissshot@mail.com",
      password: "Thepaswordisnil"
    )

    user = User.new(
      username: "Shinobu",
      email: "snailsnail@mail.com",
      password: "thiscanbewhateverawr"
    )

    user.valid?
    expect(user.errors[:username]).to include("has already been taken")
  end

  it "User should be created with user_level of :user by default" do
    user = User.new(
      username: "Shinobu",
      email: "kissshot@mail.com",
      password: "Thepaswordisnil",
      )

    expect(user.user_level.to_sym).to eq :user
  end
end
