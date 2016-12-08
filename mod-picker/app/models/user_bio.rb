class UserBio < ActiveRecord::Base
  include BetterJson

  belongs_to :user

  # VALIDATIONS
  validates :user_id, presence: true
  validates :nexus_user_path, :lover_user_path, :workshop_user_path, length: { maximum: 64 }
  validates :nexus_username, :lover_username, :workshop_username, length: { maximum: 32 }

  # CALLBACKS
  after_create :generate_verification_tokens
  after_update :update_user_reputation

  # CONSTANTS
  SITE_CODES = {
      "Nexus Mods" => "nexus",
      "Lover's Lab" => "lover",
      "Steam Workshop" => "workshop"
  }

  def get_token
    "ModPicker:#{SecureRandom.hex(4).to_s.upcase}"
  end

  def generate_verification_tokens
    self.nexus_verification_token = get_token
    self.lover_verification_token = get_token
    self.workshop_verification_token = get_token
    self.save
  end

  def update_user_reputation
    user.reputation.recompute(DateTime.now)
  end

  def verify_account(site_label, user_path)
    begin
      method_name = "verify_#{SITE_CODES[site_label]}_account"
      public_send(method_name, user_path) if respond_to?(method_name)
    rescue RestClient::NotFound => e
      raise " we couldn't find a #{site_label} user at that URL"
    end
  end

  def reset_account(site)
    public_send("#{site}_verification_token=", get_token)
    public_send("#{site}_user_path=", nil)
    public_send("#{site}_username=", nil)
    public_send("#{site}_date_joined=", nil) if respond_to?("#{site}_date_joined=")
    public_send("#{site}_posts_count=", 0) if respond_to?("#{site}_posts_count=")
    public_send("#{site}_submissions_count=", 0) if respond_to?("#{site}_submissions_count=")
    public_send("#{site}_followers_count=", 0) if respond_to?("#{site}_followers_count=")
    save
  end

  def write_user_data(site, user_path, user_data, stat_data=nil)
    public_send("#{site}_user_path=", user_path)
    public_send("#{site}_username=", user_data[:username])
    public_send("#{site}_date_joined=", user_data[:date_joined]) if user_data.has_key?(:date_joined)
    public_send("#{site}_posts_count=", user_data[:posts_count]) if user_data.has_key?(:posts_count)
    public_send("#{site}_submissions_count=", stat_data[:submissions_count]) if stat_data.present?
    public_send("#{site}_followers_count=", stat_data[:followers_count]) if stat_data.present?
  end

  def verify_nexus_account(user_path)
    # exit if we don't have a nexus_user_path
    return false if user_path.nil?

    # scrape using the Nexus Helper
    user_data = NexusHelper.scrape_user(user_path)

    # verify the token, write data, populate mod author records, and save
    if user_data[:last_status] == nexus_verification_token
      write_user_data(:nexus, user_path, user_data)
      ModAuthor.link_author(NexusInfo, user_id, nexus_username)
      save
    end
  end

  def reset_nexus_account
    reset_account(:nexus)
  end

  def verify_lover_account(user_path)
    # exit if we don't have an account_path
    return false if user_path.nil?

    # scrape using the Lover Helper
    user_data = LoverHelper.scrape_user(user_path)

    # verify the token, write data, populate mod author records, and save
    if user_data[:last_status] == lover_verification_token
      write_user_data(:lover, user_path, user_data)
      ModAuthor.link_author(LoverInfo, user_id, lover_username)
      save
    end
  end

  def reset_lover_account
    reset_account(:lover)
  end

  def verify_workshop_account(user_path)
    # exit if we don't have a steam_username
    return false if user_path.nil?

    # scrape using the workshop helper
    user_data = WorkshopHelper.scrape_user(user_path)

    # verify the token, scrape workshop stats, write data, populate mod author records, and save
    if user_data[:matched_comment] == workshop_verification_token
      workshop_stats = WorkshopHelper.scrape_workshop_stats(user_path)
      write_user_data(:workshop, user_path, user_data, workshop_stats)
      ModAuthor.link_author(WorkshopInfo, user_id, workshop_username)
      save
    end
  end

  def reset_workshop_account
    reset_account(:workshop)
  end
end
