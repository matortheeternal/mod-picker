class NexusInfo < ActiveRecord::Base
  include Scrapeable

  # ASSOCIATIONS
  belongs_to :mod
  belongs_to :game, :inverse_of => 'nexus_infos'

  # VALIDATIONS
  validates :game_id, :mod_name, :uploaded_by, :authors, :released, presence: true

  def scrape
    # scrape using the Nexus Helper
    mod_data = NexusHelper.scrape_mod(game.nexus_name, id)

    # write the scraping results to the nexus info record
    self.assign_attributes(mod_data)

    # save scraped data
    self.save!

    after_scrape
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
end
