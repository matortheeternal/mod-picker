class NexusInfo < ActiveRecord::Base
  include Scrapeable, BetterJson

  # ASSOCIATIONS
  belongs_to :mod
  belongs_to :game, :inverse_of => 'nexus_infos'

  # VALIDATIONS
  validates :game_id, :mod_name, :uploaded_by, :authors, :released, presence: true

  def self.prepare_for_mod(id, game_id)
    raise "cannot scrape Nexus Info with no game id" unless game_id
    info = NexusInfo.find_or_initialize_by(id: id, game_id: game_id)
    raise Exceptions::ModExistsError.new(info.mod) if info.mod_id
    info
  end

  def scrape
    # scrape using the Nexus Helper
    mod_data = NexusHelper.scrape_mod(game.nexus_name, id)

    # write the scraping results to the nexus info record
    self.assign_attributes(mod_data)

    # save scraped data
    self.save!

    after_scrape
  end

  def self.edit_json_format
    { :only => [:id, :last_scraped] }
  end

  def self.base_json_format
    { :except => [:mod_id] }
  end

  def notification_json_options(event_type)
    {
        :only => [],
        :include => { :mod => Mod.base_json_format }
    }
  end

  def url
    NexusHelper.mod_url(game.nexus_name, id)
  end

  def after_scrape
    compute_extra_metrics
    if mod_id.present? && Rails.application.config.scrape_nexus_statistics && mod.reviews_count < 5
      mod.compute_reputation
      mod.save!
    end
  end

  def link_uploader
    bio = UserBio.find_by(nexus_username: uploaded_by)
    if bio.present? && mod_id.present?
      ModAuthor.find_or_create_by(mod_id: mod_id, user_id: bio.user_id)
    end
  end

  def compute_extra_metrics
    days_since_release = DateTime.now - released.to_date
    if Rails.application.config.scrape_nexus_statistics
      self.endorsement_rate = (endorsements / days_since_release) if days_since_release > 0
      self.dl_rate = (unique_downloads / days_since_release) if days_since_release > 0
      self.udl_to_endorsements = (unique_downloads / endorsements) if endorsements > 0
      self.udl_to_posts = (unique_downloads / posts_count) if posts_count > 0
      self.tdl_to_udl = (total_downloads / unique_downloads) if unique_downloads > 0
      self.views_to_tdl = (views / total_downloads) if total_downloads > 0
      save!
    end
  end

  def endorsement_reputation
    100.0 / (1.0 + Math::exp(-0.15 * (endorsement_rate - 25)))
  end

  def self.can_scrape_statistics?
    Rails.application.config.scrape_nexus_statistics
  end
end
