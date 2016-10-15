module Scrapeable
  extend ActiveSupport::Concern

  included do
    # Scopes
    scope :can_recrape, -> {
      table = arel_table
      joins(:mod).where(:mods => {hidden: false}).
        where(table[:last_scraped].lt(7.days.ago).
              or(table[:released].gt(7.days.ago)))
    }

    # CALLBACKS
    after_save :update_mod_dates
  end

  def update_mod_dates
    return if mod_id.blank?

    hash = Hash.new
    hash[:updated] = updated if mod.updated.nil? || mod.updated < updated
    hash[:released] = released if mod.released.nil? || mod.released > released

    mod.update_columns(hash) if hash.any?
  end

  def rescrape
    if last_scraped.nil? || last_scraped < 1.week.ago
      scrape
    end
  end
end