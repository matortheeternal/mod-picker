require 'nokogiri'
require 'open-uri'

class WorkshopInfo < ActiveRecord::Base
  belongs_to :mod
  belongs_to :game, :inverse_of => 'workshop_infos'

  # Validations
  validates :game_id, :mod_name, :uploaded_by, :released, presence: true

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
    # scrape using the Workshop Helper
    mod_data = WorkshopHelper.scrape_mod(id)

    # write the scraping results to the workshop info record
    self.assign_attributes(mod_data)

    # save scraped data
    self.save!
  end

  def rescrape
    if self.last_scraped.nil? || self.last_scraped < 1.week.ago
      self.scrape
    end
  end
end
