# This file and all spec fils should mirror the app directory.
# for instance, this user_spec spec should have a user file in the app/models
# directory for the actual model.
require 'rails_helper'

describe User do

  # Validations ====================================================
  
  it "is valid with a username, email, and password" do
    user = build(:user)
    expect(user).to be_valid
  end

  it "is invalid without a password" do
    user = build(:user,
      password: nil
      )
    user.valid?
    expect(user.errors[:password]).to include("can't be blank")
  end

  it "is invalid without a username" do
    user = build(:user,
      username: nil,
      )
    user.valid?
    expect(user.errors[:username]).to include("can't be blank")
  end

  it "is invalid without an email" do
    user = build(:user,
      email: nil,
    )
    user.valid?
    expect(user.errors[:email]).to include("can't be blank")
  end

  it "is invalid with a duplicate email address" do
    create(:user,
      email: "kissshot@mail.com")

    user = build(:user,
      email: "kissshot@mail.com",
    )

    user.valid?
    expect(user.errors[:email]).to include("has already been taken")
  end

  it "is invalid with a duplicate username" do
    create(:user,
      username: "Shinobu",
    )

    user = build(:user,
      username: "Shinobu",
    )

    user.valid?
    expect(user.errors[:username]).to include("has already been taken")
  end

  context "#init" do
    it "joined should exist" do
      user = create(:user)
      expect(user.joined).to eq DateTime.current
    end

    it "title should be prisoner" do
      user = create(:user)
      expect(user.title.to_sym).to eq :Prisoner
    end

    it "avatar should be newUser.jpg" do
      user = create(:user)
      expect(user.avatar). to eq "NewUser.png"
    end

    it "user_level should be created with user_level of :user" do
      user = create(:user)
      expect(user.user_level.to_sym).to eq :user
    end
  end
end
