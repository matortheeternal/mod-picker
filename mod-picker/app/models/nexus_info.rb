require 'nokogiri'
require 'open-uri'

class NexusInfo < ActiveRecord::Base
  belongs_to :mod
  belongs_to :game, :inverse_of => 'nexus_infos'

  validates_presence_of :game_id

  def scrape
    # scrape using the Nexus Helper
    mod_data = NexusHelper.scrape_mod(game.nexus_name, id)

    # write the scraping results to the nexus info record
    self.assign_attributes(mod_data)

    # save scraped data
    self.save!
  end

  def rescrape
    if self.last_scraped.nil? || self.last_scraped < 1.week.ago
      self.scrape
      self.mod.compute_extra_metrics
      if self.mod.reviews_count < 5
        self.mod.compute_reputation
      end
    end
  end
end
