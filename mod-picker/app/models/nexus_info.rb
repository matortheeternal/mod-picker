require 'nokogiri'
require 'open-uri'

class NexusInfo < ActiveRecord::Base
  belongs_to :mod
  belongs_to :game, :inverse_of => 'nexus_infos'

  validates_presence_of :id, :game_id

  def nexus_mods_url
    "http://www.nexusmods.com/#{game.nexus_name}/mods/#{id}"
  end

  def scrape_rate
    1.week.to_i
  end

  def nexus_date_format
    '%d/%m/%Y - %I:%M%p'
  end

  def scrape
    # get the nexus mods page
    doc = Nokogiri::HTML(open(nexus_mods_url))

    # scrape basic data
    self.last_scraped = DateTime.now
    self.modName = doc.at_css(".header-name").text
    self.currentVersion = doc.at_css(".file_version").text
    self.authors = doc.at_css(".header-author").text
    self.endorsements = doc.at_css("#span_endors_number").text
    self.unique_downloads = doc.at_css(".file-unique-dls").text
    self.total_downloads = doc.at_css(".file-total-dls").text
    self.views = doc.at_css(".file-total-views").text
    self.uploaded_by = doc.at_css(".uploader").text

    # parse dates
    dates = doc.at_css(".header-dates").text
    date_released_str = /Added:<\/strong> ([^<]*)/.match(dates).captures[0]
    self.date_released = DateTime.parse(date_released_str, nexus_date_format)
    date_updated_str = /Updated:<\/strong> ([^<]*)/.match(dates).captures[0]
    self.date_updated = DateTime.parse(date_updated_str, nexus_date_format)

    # parse nexus category
    cat = doc.at_css(".header-cat").text
    self.nexus_category = /src_cat=([0-9]*)/.match(cat).captures[0].to_i
  end

  def rescrape
    if (DateTime.now - self.last_scraped) > scrape_rate
      self.scrape
    end
  end
end
