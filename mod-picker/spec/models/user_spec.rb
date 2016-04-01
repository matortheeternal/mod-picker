# This file and all spec fils should mirror the app directory.
# for instance, this user_spec spec should have a user file in the app/models
# directory for the actual model.
require 'rails_helper'

RSpec.describe User, :model do

  fixtures :users
  # Validations ====================================================
  
  it "should be valid with a username, email, and password" do
    user = build(:user)
    expect(user).to be_valid
  end

  it "should have a valid fixture" do
    expect(users(:kyoko)).to be_valid
  end

  it "should be invalid without a password" do
    user = build(:user,
      password: nil
      )
    user.valid?
    expect(user.errors[:password]).to include("can't be blank")
  end

  it "should be invalid without an email" do
    user = build(:user,
      email: nil,
      )
    user.valid?
    expect(user.errors[:email]).to include("can't be blank")
  end


  # ==================================================================
  # Username Validations
  # ==================================================================
  
  context "username" do
    it "should be invalid with a duplicate username" do
      create(:user,
        username: "Shinobu",
        )

      user = build(:user,
        username: "Shinobu",
        )

      user.valid?
      expect(user.errors[:username]).to include("has already been taken")
    end

    it "should be invalid with a duplicate username of different case" do
      create(:user,
        username: "Karen",
        )

      user = build(:user,
        username: "KaREN",
        )

      user.valid?
      expect(user.errors[:username]).to include("has already been taken")
    end

    it "should be invalid without a username" do
      user = build(:user,
        username: nil,
        )
      user.valid?
      expect(user.errors[:username]).to include("can't be blank")
    end

    it "should be invalid with a username length < 4" do
      user = build(:user,
        username: "hoa")
      user.valid?
      expect(user.errors[:username]).to include("is too short (minimum is 4 characters)")
    end


    it "should be invalid with a username length > 20" do
      user = build(:user,
        username: "aaaabbbbaaaabbbbaaaabb")
      user.valid?
      expect(user.errors[:username]).to include("is too long (maximum is 20 characters)")
    end

    it "should be valid with a username length >= 4  and length <= 20" do
      user = build(:user,
        username: "holofoam")

      valid_usernames = %w[four reDdUng TesTer TestIngmore thetwent
        thisnamefourFourfour]

        valid_usernames.each do |valid_username| 
          user.username = valid_username
          expect(user).to be_valid
        end
      end

    end

    # ==================================================================
    # Email Validations
    # ==================================================================
    
    context "email" do
      it "should be invalid without an email" do
        user = build(:user,
          email: nil,
          )
        user.valid?
        expect(user.errors[:email]).to include("can't be blank")
      end

      it "should be invalid with a duplicate email address" do
        create(:user,
          email: "kissshot@mail.com")

        user = build(:user,
          email: "kissshot@mail.com",
          )

        user.valid?
        expect(user.errors[:email]).to include("has already been taken")
      end

      it "should be invalid with a duplicate email address of different case" do
        create(:user,
          email: "kissshot@mail.com")

        user = build(:user,
          email: "kissSHOT@MAIl.com",
          )

        user.valid?
        expect(user.errors[:email]).to include("has already been taken")
      end

      it "should be invalid with a email length < 7" do
        user = build(:user,
          email: "@m.com")
        user.valid?
        expect(user.errors[:email]).to include("is too short (minimum is 7 characters)")
      end


      it "should be invalid with a email length > 100" do
        email_name = ("a" * 92) + "@mail.com"

        user = build(:user,
          email: email_name)

        user.valid?
        expect(user.errors[:email]).to include("is too long (maximum is 100 characters)")
      end

      it "should be valid with a username length >= 4  and length <= 20" do
        user = build(:user)

        valid_emails = %w[tester@mail.com foobar@mail.something.com foo.bar@mail.com
          moo_car@mail.com red.blue@mail.com]

          valid_emails.each do |valid_email| 
            user.email = valid_email
            expect(user).to be_valid
          end
        end

      end

      # ==================================================================
      # #init method validations
      # ==================================================================
      context "#init" do
        it "should initialize joined to DateTime.now" do
          user = create(:user)
          expect(user.joined.utc).to be_within(1.minute).of DateTime.current.utc
        end

        it "should be created with role of :user" do
          user = create(:user)
          expect(user.role.to_sym).to eq :user
        end
      end
    end
