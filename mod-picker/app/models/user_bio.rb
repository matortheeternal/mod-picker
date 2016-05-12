class UserBio < ActiveRecord::Base
  belongs_to :user

  after_create :generate_verification_tokens

  def generate_verification_tokens
    self.nexus_verification_token = "ModPicker:#{SecureRandom.hex(4).to_s.upcase}"
    self.lover_verification_token = "ModPicker:#{SecureRandom.hex(4).to_s.upcase}"
    self.workshop_verification_token = "ModPicker:#{SecureRandom.hex(4).to_s.upcase}"
    self.save
  end

  def verify_nexus_account
    # exit if we don't have a nexus_user_path
    if self.nexus_user_path.nil?
      return false
    end

    # scrape using the Nexus Helper
    user_data = NexusHelper.scrape_user(self.nexus_user_path)

    # verify the token
    if user_data[:last_status] == self.nexus_verification_token
      self.nexus_username = user_data[:username]
      self.nexus_date_joined = user_data[:date_joined]
      self.nexus_posts_count = user_data[:posts_count]
      true
    end
  end

  def verify_lover_account
    # exit if we don't have a lover_user_path
    if self.lover_user_path.nil?
      return false
    end

    # scrape using the Lover Helper
    user_data = LoverHelper.scrape_user(self.lover_user_path)

    # verify the token
    if user_data[:last_status] == self.lover_verification_token
      self.lover_username = user_data[:username]
      self.lover_date_joined = user_data[:date_joined]
      self.lover_posts_count = user_data[:posts_count]
      true
    end
  end
end
