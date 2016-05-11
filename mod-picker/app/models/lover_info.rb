class LoverInfo < ActiveRecord::Base
  belongs_to :mod
  belongs_to :game

  def scrape
    # retrieve using the Lover Helper
    mod_data = LoverHelper.retrieve_mod(id)

    # remove screenshot field
    screenshot = mod_data.delete("screenshot")
    mod_data["game_id"] = Game.find_by(nexus_name: mod_data.delete("game")).id

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
