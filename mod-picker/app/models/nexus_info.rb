require 'nokogiri'
require 'open-uri'

class NexusInfo < ActiveRecord::Base
  belongs_to :mod
  belongs_to :game, :inverse_of => 'nexus_infos'

  validates_presence_of :id, :game_id

  def nexus_mods_url
    "http://www.nexusmods.com/#{game.nexus_name}/mods/#{id}"
  end

  def scrape
    doc = Nokogiri::HTML(open(nexus_mods_url))
    self.last_scraped = DateTime.now
    self.modName = doc.at_css(".header-name").text
    self.currentVersion = doc.at_css(".file_version").text
    self.authors = doc.at_css(".header-author").text
    self.endorsements = doc.at_css("#span_endors_number").text
    self.unique_downloads = doc.at_css(".file-unique-dls").text
    self.total_downloads = doc.at_css(".file-total-dls").text
    self.views = doc.at_css(".file-total-views").text
    self.uploaded_by = doc.at_css(".uploader").text
    dates = doc.at_css(".header-dates").text
    self.date_released = /Added:<\/strong> ([^<]*)/.match(dates).captures
    self.date_updated = /Updated:<\/strong> ([^<]*)/.match(dates).captures
    cat = doc.at_css(".header-cat").text
    self.nexus_category = /src_cat=([0-9]*)/.match(cat).captures
  end

  def rescrape
    if (DateTime.now - self.last_scraped) > 1.week.to_i
      self.scrape
    end
  end
end
