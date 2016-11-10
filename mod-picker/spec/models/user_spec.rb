# This file and all spec fils should mirror the app directory.
# for instance, this user_spec spec should have a user file in the app/models
# directory for the actual model.

# create_table "users", force: :cascade do |t|
#     t.string   "username",                  limit: 32
#     t.string   "role",                      limit: 16
#     t.string   "title",                     limit: 32
#     t.datetime "joined"
#     t.integer  "active_mod_list_id",        limit: 4
#     t.string   "email",                     limit: 255,   default: "", null: false
#     t.string   "encrypted_password",        limit: 255,   default: "", null: false
#     t.string   "reset_password_token",      limit: 255
#     t.datetime "reset_password_sent_at"
#     t.datetime "remember_created_at"
#     t.integer  "sign_in_count",             limit: 4,     default: 0,  null: false
#     t.datetime "current_sign_in_at"
#     t.datetime "last_sign_in_at"
#     t.string   "current_sign_in_ip",        limit: 255
#     t.string   "last_sign_in_ip",           limit: 255
#     t.string   "confirmation_token",        limit: 255
#     t.datetime "confirmed_at"
#     t.datetime "confirmation_sent_at"
#     t.integer  "comments_count",            limit: 4,     default: 0
#     t.integer  "reviews_count",             limit: 4,     default: 0
#     t.integer  "install_order_notes_count", limit: 4,     default: 0
#     t.integer  "compatibility_notes_count", limit: 4,     default: 0
#     t.integer  "corrections_count",     limit: 4,     default: 0
#     t.integer  "agreement_marks_count",     limit: 4,     default: 0
#     t.integer  "mods_count",                limit: 4,     default: 0
#     t.integer  "starred_mods_count",        limit: 4,     default: 0
#     t.integer  "starred_mod_lists_count",   limit: 4,     default: 0
#     t.integer  "profile_comments_count",    limit: 4,     default: 0
#     t.integer  "mod_stars_count",           limit: 4,     default: 0
#     t.text     "about_me",                  limit: 65535
#     t.integer  "load_order_notes_count",    limit: 4,     default: 0
#     t.string   "invitation_token",          limit: 255
#     t.datetime "invitation_created_at"
#     t.datetime "invitation_sent_at"
#     t.datetime "invitation_accepted_at"
#     t.integer  "invitation_limit",          limit: 4
#     t.integer  "invited_by_id",             limit: 4
#     t.string   "invited_by_type",           limit: 255
#     t.integer  "invitations_count",         limit: 4,     default: 0
#   end

# Validations

# validates :username,
# presence: true,
# uniqueness: {
#   case_sensitive: false
# },
# length: {in: 4..20 }

# # TODO: add email regex
# # basic one, minimize false negatives and confirm users via email confirmation regardless
# validates :email,
# presence: true,
# uniqueness: {
#   case_sensitive: false
# },
# length: {in: 7..254}
# # format: {
# # with: VALID_EMAIL_REGEX,
# # message: must be a valid email address format
# # }

# validates :role, presence: true
# validates :about_me, length: {maximum: 16384}


# validate :validate_username

# def validate_username
#   if User.where(email: username).exists?
#     errors.add(:username, :invalid)
#   end
# end

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


      it "should be invalid with a email length > 254" do
        email_name = ("a" * 254) + "@mail.com"

        user = build(:user,
          email: email_name)

        user.valid?
        expect(user.errors[:email]).to include("is too long (maximum is 254 characters)")
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
