class LoverInfo < ActiveRecord::Base
  belongs_to :mod
  belongs_to :game

  # Callbacks
  after_save :update_mod_dates

  def update_mod_dates
    if self.mod_id.blank?
      return
    end

    hash = Hash.new
    hash[:updated] = self.date_updated if self.mod.updated < self.date_updated
    hash[:released] = self.date_submitted if self.mod.released > self.date_submitted

    if hash.any?
      self.mod.update_columns(hash)
    end
  end

  def scrape
    # retrieve using the Lover Helper
    mod_data = LoverHelper.retrieve_mod(id)

    # write the results to the lover info record
    self.assign_attributes(mod_data)

    # save retrieved mod data
    self.save!
  end

  def rescrape
    if self.last_scraped.nil? || self.last_scraped < 1.week.ago
      self.scrape
    end
  end
end
