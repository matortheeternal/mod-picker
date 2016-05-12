require 'securerandomext'

class UserBio < ActiveRecord::Base
  belongs_to :user

  after_create :generate_verification_tokens

  def generate_verification_tokens
    self.nexus_verification_token = "ModPicker:#{SecureRandomExt.base58(16)}"
    self.lover_verification_token = "ModPicker:#{SecureRandomExt.base58(16)}"
    self.save
  end

  def verify_nexus_account
    # exit if we don't have a nexus_user_path
    if self.nexus_user_path.nil?
      return
    end

    # scrape using the Nexus Helper
    user_data = NexusHelper.scrape_user(self.nexus_user_path)

    # verify the token
    if user_data[:last_status] == self.nexus_verification_token
      self.nexus_username = user_data[:username]
      self.nexus_date_joined = user_data[:date_joined]
      self.nexus_posts_count = user_data[:posts_count]
    end
  end

  def verify_lover_account
    # exit if we don't have a lover_user_path
    if self.lover_user_path.nil?
      return
    end

    # scrape using the Lover Helper
    user_data = LoverHelper.scrape_user(self.lover_user_path)

    # verify the token
    if user_data[:last_status] == self.lover_verification_token
      self.lover_username = user_data[:username]
      self.lover_date_joined = user_data[:date_joined]
      self.lover_posts_count = user_data[:posts_count]
    end
  end

  def verify_workshop_account
    # exit if we don't have a steam_username
    if self.workshop_username.nil?
      return
    end

    # scrape using the workshop helper
    user_data = WorkshopHelper.scrape_user(self.workshop_username)

    # verify the token
    if user_data[:last_comment] == self.workshop_verification_token
      workshop_stats = WorkshopHelper.scrape_workshop_stats(self.workshop_username)
      self.workshop_submissions_count = workshop_stats[:submissions_count]
      self.workshop_followers_count = workshop_stats[:followers_count]
      self.workshop_verified = true
    end
  end
end
