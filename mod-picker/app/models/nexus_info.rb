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
    self.mod_name = doc.at_css(".header-name").text
    self.current_version = doc.at_css(".file-version strong").text
    self.authors = doc.at_css(".header-author strong").text
    self.endorsements = doc.at_css("#span_endors_number").text.gsub(',', '')
    self.unique_downloads = doc.at_css(".file-unique-dls strong").text.gsub(',', '')
    self.total_downloads = doc.at_css(".file-total-dls strong").text.gsub(',', '')
    self.views = doc.at_css(".file-total-views strong").text.gsub(',', '')
    self.uploaded_by = doc.at_css(".uploader a").text

    # parse dates
    dates = doc.at_css(".header-dates").css('div')
    date_added_str = dates[0].children[1].text.strip
    self.date_added = DateTime.parse(date_added_str, nexus_date_format)
    date_updated_str = dates[1].children[1].text.strip
    self.date_updated = DateTime.parse(date_updated_str, nexus_date_format)

    # parse nexus category
    catlink = doc.at_css(".header-cat").css('a/@href')[1].text
    self.nexus_category = /src_cat=([0-9]*)/.match(catlink).captures[0].to_i
  end

  def rescrape
    if (DateTime.now - self.last_scraped) > scrape_rate
      self.scrape
    end
  end
end
