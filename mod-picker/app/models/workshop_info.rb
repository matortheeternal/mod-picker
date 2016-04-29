class WorkshopInfo < ActiveRecord::Base
  belongs_to :mod

  def steam_workshop_url
    "http://steamcommunity.com/sharedfiles/filedetails/#{id}"
  end

  def workshop_date_format
    '%M %d, %Y @ %I:%M%p'
  end


  def scrape
    # get the workshop page
    doc = Nokogiri::HTML(open(steam_workshop_url))

    # scrape basic data
    self.last_scraped = DateTime.now
    self.mod_name = doc.at_css(".workshopItemTitle").text
    self.uploaded_by = doc.at_css(".creatorsBlock .friendBlockContent").text

    # scrape dates
    # <.detailsStatsContainerRight>
    stats = doc.at_css(".detailsStatsContainerRight").css(".detailsStatRight")
    date_submitted_str = stats[1].text.strip
    self.date_submitted = DateTime.parse(date_submitted_str, workshop_date_format)
    date_updated_str = stats[2].text.strip
    self.date_updated = DateTime.parse(date_updated_str, workshop_date_format)

    # scrape statistics
    if Rails.application.config.scrape_workshop_statistics
      self.file_size = stats[0].text.gsub(' MB', '').to_i * 1024 * 1024
      # <.sectionTabs>
      sectionTabs = doc.at_css(".sectionTabs").css(".sectionTab")
      self.discussions_count = sectionTabs[1].css(".tabCount").text.to_i
      self.comments_count = sectionTabs[1].css(".tabCount").text.to_i
      self.discussions_count = sectionTabs[2].css(".tabCount").text.to_i
      # <.stats-table>
      statsTableRows = doc.at_css(".stats-table").css("tr")
      self.views = statsTableRows[0].css("td")[0].text.gsub(',', '').to_i
      self.subscribers = statsTableRows[1].css("td")[0].text.gsub(',', '').to_i
      self.favorites = statsTableRows[2].css("td")[0].text.gsub(',', '').to_i
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
