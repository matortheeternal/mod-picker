class NexusInfo < ActiveRecord::Base
  include Scrapeable

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

  def notification_json_options(event_type)
    {
        :only => [],
        :include => {
            :mod => { :only => [:id, :name] }
        }
    }
  end

  def url
    NexusHelper.mod_url(game.nexus_name, id)
  end

  def after_scrape
    # update mod extra metrics
    if mod_id.present?
      mod.compute_extra_metrics
      if Rails.application.config.scrape_nexus_statistics && mod.reviews_count < 5
        mod.compute_reputation
        mod.save!
      end
    end
  end

  def link_uploader
    bio = UserBio.find_by(nexus_username: uploaded_by)
    if bio.present? && mod_id.present?
      ModAuthor.find_or_create_by(mod_id: mod_id, user_id: bio.user_id)
    end
  end
end
