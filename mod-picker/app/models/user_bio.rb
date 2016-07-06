class UserBio < ActiveRecord::Base
  belongs_to :user

  # Validations
  validates :user_id, presence: true
  validates :nexus_user_path, :lover_user_path, :workshop_user_path, length: { maximum: 64 }
  validates :nexus_username, :lover_username, :workshop_username, length: { maximum: 32 }

  # Callbacks
  after_create :generate_verification_tokens

  def generate_verification_tokens
    self.nexus_verification_token = "ModPicker:#{SecureRandom.hex(4).to_s.upcase}"
    self.lover_verification_token = "ModPicker:#{SecureRandom.hex(4).to_s.upcase}"
    self.workshop_verification_token = "ModPicker:#{SecureRandom.hex(4).to_s.upcase}"
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
    if user_data[:last_status] == self.nexus_verification_token
      # write fields to bio
      self.nexus_user_path = user_path
      self.nexus_username = user_data[:username]
      self.nexus_date_joined = user_data[:date_joined]
      self.nexus_posts_count = user_data[:posts_count]

      # populate mod author records
      ModAuthor.link_author(NexusInfo, self.user_id, self.nexus_username)

      # save bio
      self.save
    end
  end

  def verify_lover_account(user_path)
    # exit if we don't have an account_path
    if user_path.nil?
      return false
    end

    # scrape using the Lover Helper
    user_data = LoverHelper.scrape_user(user_path)

    # verify the token
    if user_data[:last_status] == self.lover_verification_token
      # write fields to bio
      self.lover_user_path = user_path
      self.lover_username = user_data[:username]
      self.lover_date_joined = user_data[:date_joined]
      self.lover_posts_count = user_data[:posts_count]

      # populate mod author records
      ModAuthor.link_author(LoverInfo, self.user_id, self.lover_username)

      # save bio
      self.save
    end
  end

  def verify_workshop_account(user_path)
    # exit if we don't have a steam_username
    if user_path.nil?
      return
    end

    # scrape using the workshop helper
    user_data = WorkshopHelper.scrape_user(user_path)

    # verify the token
    if user_data[:matched_comment] == self.workshop_verification_token
      # scrape user's workshop stats
      workshop_stats = WorkshopHelper.scrape_workshop_stats(user_path)

      # write fields to bio
      self.workshop_user_path = user_path
      self.workshop_username = user_data[:username]
      self.workshop_submissions_count = workshop_stats[:submissions_count]
      self.workshop_followers_count = workshop_stats[:followers_count]

      # populate mod author records
      ModAuthor.link_author(WorkshopInfo, self.user_id, self.workshop_username)

      # save bio
      self.save
    end
  end
end
