class NexusInfo < ActiveRecord::Base
  belongs_to :mod
  belongs_to :game, :inverse_of => 'nexus_infos'

  # Validations
  validates :game_id, :mod_name, :uploaded_by, :authors, :released, presence: true

  # Callbacks
  after_save :update_mod_dates

  def update_mod_dates
    if self.mod_id.blank?
      return
    end

    hash = Hash.new
    hash[:updated] = self.updated if self.mod.updated.nil? || self.mod.updated < self.updated
    hash[:released] = self.released if self.mod.released.nil? || self.mod.released > self.released

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
