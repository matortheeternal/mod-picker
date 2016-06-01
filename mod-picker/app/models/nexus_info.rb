class NexusInfo < ActiveRecord::Base
  belongs_to :mod
  belongs_to :game, :inverse_of => 'nexus_infos'

  # Validations
  validates_presence_of :game_id

  # Callbacks
  after_save :update_mod_dates

  def update_mod_dates
    if self.mod_id.blank?
      return
    end

    hash = Hash.new
    hash[:updated] = self.date_updated if self.mod.updated.nil? || self.mod.updated < self.date_updated
    hash[:released] = self.date_added if self.mod.released.nil? || self.mod.released > self.date_added

    if hash.any?
      self.mod.update_columns(hash)
    end
  end

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
