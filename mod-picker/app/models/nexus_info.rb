require 'nokogiri'
require 'open-uri'

class NexusInfo < ActiveRecord::Base
  belongs_to :mod
  belongs_to :game, :inverse_of => 'nexus_infos'

  validates_presence_of :game_id

  def nexus_mods_url
    "http://www.nexusmods.com/#{game.nexus_name}/mods/#{id}"
  end

  def nexus_date_format
    '%d/%m/%Y - %I:%M%p'
  end

  def try_parse(doc, selector, default)
    begin
      doc.at_css(selector).text
    rescue
      default
    end
  end

  def scrape
    # get the nexus mods page
    doc = Nokogiri::HTML(open(nexus_mods_url))

    # scrape basic data
    self.last_scraped = DateTime.now
    self.mod_name = doc.at_css(".header-name").text
    self.current_version = doc.at_css(".file-version strong").text
    self.authors = doc.at_css(".header-author strong").text

    # scrape dates
    dates = doc.at_css(".header-dates").css('div')
    date_added_str = dates[0].children[1].text.strip
    self.date_added = DateTime.parse(date_added_str, nexus_date_format)
    date_updated_str = dates[1].children[1].text.strip
    self.date_updated = DateTime.parse(date_updated_str, nexus_date_format)

    # scrape statistics
    if Rails.application.config.scrape_nexus_statistics
      self.endorsements = doc.at_css("#span_endors_number").text.gsub(',', '')
      self.unique_downloads = doc.at_css(".file-unique-dls strong").text.gsub(',', '')
      self.total_downloads = doc.at_css(".file-total-dls strong").text.gsub(',', '')
      self.views = doc.at_css(".file-total-views strong").text.gsub(',', '')
      self.uploaded_by = doc.at_css(".uploader a").text

      # scrape nexus category
      catlink = doc.at_css(".header-cat").css('a/@href')[1].text
      self.nexus_category = /src_cat=([0-9]*)/.match(catlink).captures[0].to_i

      # scrape counts
      self.files_count = try_parse(doc, ".tab-files strong", "0").to_i
      self.images_count = try_parse(doc, ".tab-images strong", "0").to_i
      self.articles_count = try_parse(doc, ".tab-articles strong", "0").to_i
      self.posts_count = try_parse(doc, ".tab-comments strong", "0").to_i
      self.videos_count = try_parse(doc, ".tab-videos", "0").to_i
    end

    # save scraped data
    self.save!
  end

  def rescrape
    if self.last_scraped < 1.week.ago
      self.scrape
      self.mod.compute_extra_metrics
      if self.mod.reviews_count < 5
        self.mod.compute_reputation
      end
    end
  end
end
