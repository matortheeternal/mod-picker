module Scrapeable
  extend ActiveSupport::Concern

  included do
    # Scopes
    scope :can_recrape, -> {
      table = self.arel_table
      joins(:mod).where(:mods => {hidden: false}).
        where(table[:last_scraped].lt(7.days.ago).
              or(table[:released].gt(7.days.ago)))
    }

    # Callbacks
    after_save :update_mod_dates
  end

  def update_mod_dates
    return if self.mod_id.blank?

    hash = Hash.new
    hash[:updated] = self.updated if self.mod.updated.nil? || self.mod.updated < self.updated
    hash[:released] = self.released if self.mod.released.nil? || self.mod.released > self.released

    self.mod.update_columns(hash) if hash.any?
  end

  def rescrape
    if self.last_scraped.nil? || self.last_scraped < 1.week.ago
      self.scrape
    end
  end
end