require 'nokogiri'
require 'open-uri'

class LoverInfo < ActiveRecord::Base
  belongs_to :mod

  def lovers_lab_url
    "http://www.loverslab.com/files/file/#{id}"
  end

  def lab_date_format
    '%b %d %Y %I:%M %p'
  end

  def scrape
    # get the mod page
    doc = Nokogiri::HTML(open(lovers_lab_url))

    # scrape basic data
    self.last_scraped = DateTime.now
    self.mod_name = doc.at_css(".ipsType_pagetitle").children[2].text.strip
    self.uploaded_by = doc.at_css("#submitter_info .ipsType_subtitle").text.strip

    # scrape dates
    file_information_items = doc.at_css(".ipsList_data").css("li")
    date_submitted_str = file_information_items[0].children[2].text.strip
    self.date_submitted = DateTime.parse(date_submitted_str, lab_date_format)
    date_updated_str = file_information_items[1].children[2].text.strip
    self.date_updated = DateTime.parse(date_updated_str, lab_date_format)

    # scrape statistics
    self.has_stats = Rails.application.config.scrape_lab_statistics
    if Rails.application.config.scrape_lab_statistics
      self.file_size = file_information_items[2].children[2].text.gsub('MB', '').to_f * 1024 * 1024
      self.views = file_information_items[3].children[2].text.to_i
      self.downloads = file_information_items[4].children[2].text.gsub(',', '').to_i
      self.followers_count = doc.at_css(".__like .ipsButton_extra strong").text.to_i
    end

    # save scraped data
    self.save!
  end

  def rescrape
    if self.last_scraped < 1.week.ago
      self.scrape
    end
  end
end
