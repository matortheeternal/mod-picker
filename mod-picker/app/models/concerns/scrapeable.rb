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
    hash[:updated] = updated if updated && (mod.updated.nil? || mod.updated < updated)
    hash[:released] = released if released && (mod.released.nil? || mod.released > released)

    mod.update_columns(hash) if hash.any?
  end

  def rescrape
    return unless last_scraped.nil? || last_scraped < 1.week.ago
    scrape
  rescue Exception => e
    puts e
  end
end