class UserBio < ActiveRecord::Base
  belongs_to :user

  # VALIDATIONS
  validates :user_id, presence: true
  validates :nexus_user_path, :lover_user_path, :workshop_user_path, length: { maximum: 64 }
  validates :nexus_username, :lover_username, :workshop_username, length: { maximum: 32 }

  # CALLBACKS
  after_create :generate_verification_tokens

  def get_token
    "ModPicker:#{SecureRandom.hex(4).to_s.upcase}"
  end

  def generate_verification_tokens
    self.nexus_verification_token = get_token
    self.lover_verification_token = get_token
    self.workshop_verification_token = get_token
    self.save
  end

  def verify_nexus_account(user_path)
    # exit if we don't have a nexus_user_path
    if user_path.nil?
      return false
    end

    # scrape using the Nexus Helper
    user_data = NexusHelper.scrape_user(user_path)

    # verify the token
    if user_data[:last_status] == nexus_verification_token
      # write fields to bio
      self.nexus_user_path = user_path
      self.nexus_username = user_data[:username]
      self.nexus_date_joined = user_data[:date_joined]
      self.nexus_posts_count = user_data[:posts_count]

      # populate mod author records
      ModAuthor.link_author(NexusInfo, user_id, nexus_username)

      # save bio
      save!
    end
  end

  def reset_nexus_account
    self.nexus_verification_token = get_token
    self.nexus_user_path = nil
    self.nexus_username = nil
    self.nexus_date_joined = nil
    self.nexus_posts_count = 0
    save
  end

  def verify_lover_account(user_path)
    # exit if we don't have an account_path
    if user_path.nil?
      return false
    end

    # scrape using the Lover Helper
    user_data = LoverHelper.scrape_user(user_path)

    # verify the token
    if user_data[:last_status] == lover_verification_token
      # write fields to bio
      self.lover_user_path = user_path
      self.lover_username = user_data[:username]
      self.lover_date_joined = user_data[:date_joined]
      self.lover_posts_count = user_data[:posts_count]

      # populate mod author records
      ModAuthor.link_author(LoverInfo, user_id, lover_username)

      # save bio
      save!
    end
  end

  def reset_lover_account
    self.lover_verification_token = get_token
    self.lover_user_path = nil
    self.lover_username = nil
    self.lover_date_joined = nil
    self.lover_posts_count = 0
    save
  end

  def verify_workshop_account(user_path)
    # exit if we don't have a steam_username
    if user_path.nil?
      return
    end

    # scrape using the workshop helper
    user_data = WorkshopHelper.scrape_user(user_path)

    # verify the token
    if user_data[:matched_comment] == workshop_verification_token
      # scrape user's workshop stats
      workshop_stats = WorkshopHelper.scrape_workshop_stats(user_path)

      # write fields to bio
      self.workshop_user_path = user_path
      self.workshop_username = user_data[:username]
      self.workshop_submissions_count = workshop_stats[:submissions_count]
      self.workshop_followers_count = workshop_stats[:followers_count]

      # populate mod author records
      ModAuthor.link_author(WorkshopInfo, user_id, workshop_username)

      # save bio
      save!
    end
  end

  def reset_workshop_account
    self.workshop_verification_token = get_token
    self.workshop_user_path = nil
    self.workshop_username = nil
    self.workshop_submissions_count = 0
    self.workshop_followers_count = 0
    save
  end
end
