require 'nokogiri'
require 'rest-client'

class WorkshopHelper
  def self.scrape_user(id)
    # construct user url
    # ex. http://steamcommunity.com/id/Naricissu/
    user_url = 'http://steamcommunity.com/id/' + id

    # prepare headers
    headers = {
        :"user-agent" => Rails.application.config.user_agent
    }

    # get the user page
    response = RestClient.get(user_url, headers)
    @last_request = DateTime.now

    # Comment blocks == div.commentthread_comment_content (this is an individual block)
    # Comment Author == div.commentthread_comment_content > div.commentthread_comment_author > a href
    # Comment body   == div.commentthread_comment_text

    # parse needed data from user page
    doc = Nokogiri::HTML(response.body)
    user_data = {}

    # .css searches for every occurence of the accessor
    # .at_css searches for the first occurence
    allComments = doc.css("div.commentthread_comments div.commentthread_comment_content")

    allComments.each do |comment| 
      author_url = comment.at_css("div.commentthread_comment_author a")["href"]
      author_display_name = comment.at_css("div.commentthread_comment_author a bdi").text.strip
      comment_body = comment.at_css("div.commentthread_comment_text").text.strip

      puts "Author url ==" + author_url
      puts "Comment body ==" + comment_body

      # Case insensitive comparison of comment author's profile urls
      if author_url.casecmp(user_url) == 0
        user_data[:matched_comment] = comment_body
        user_data[:username] = author_display_name
      end
    end

    # return user data
    user_data
  end

  def self.workshop_date_format
    '%b %d, %Y @ %I:%M%p'
  end

  def self.scrape_mod(id)
    # construct mod url
    mod_url = "http://steamcommunity.com/sharedfiles/filedetails/#{id}"

    # prepare headers
    headers = {
        :"user-agent" => Rails.application.config.user_agent
    }

    # get the mod page
    response = RestClient.get(mod_url, headers)

    # parse needed data from the mod page
    doc = Nokogiri::HTML(response.body)
    mod_data = {}

    # scrape basic data
    mod_data[:last_scraped] = DateTime.now
    mod_data[:mod_name] = doc.at_css(".workshopItemTitle").text
    mod_data[:uploaded_by] = doc.at_css(".creatorsBlock .friendBlockContent").children[0].text.strip

    # scrape dates
    # <.detailsStatsContainerRight>
    stats = doc.at_css(".detailsStatsContainerRight").css(".detailsStatRight")
    date_submitted_str = stats[1].text.strip
    mod_data[:date_submitted] = DateTime.parse(date_submitted_str, workshop_date_format)
    date_updated_str = stats[2].text.strip
    mod_data[:date_updated] = DateTime.parse(date_updated_str, workshop_date_format)

    # scrape statistics
    mod_data[:has_stats] = Rails.application.config.scrape_workshop_statistics
    if Rails.application.config.scrape_workshop_statistics
      mod_data[:file_size] = stats[0].text.gsub(' MB', '').to_f * 1024 * 1024
      # <.sectionTabs>
      sectionTabs = doc.at_css(".sectionTabs").css(".sectionTab")
      mod_data[:discussions_count] = sectionTabs[1].css(".tabCount").text.to_i
      mod_data[:comments_count] = sectionTabs[2].css(".tabCount").text.to_i
      # <.stats-table>
      statsTableRows = doc.at_css(".stats_table").css("tr")
      mod_data[:views] = statsTableRows[0].css("td")[0].text.gsub(',', '').to_i
      mod_data[:subscribers] = statsTableRows[1].css("td")[0].text.gsub(',', '').to_i
      mod_data[:favorites] = statsTableRows[2].css("td")[0].text.gsub(',', '').to_i
      # <#highlight_strip_scroll>
      highlightStrip = doc.at_css("#highlight_strip_scroll")
      mod_data[:images_count] = highlightStrip.css(".highlight_strip_screenshot").length
      mod_data[:videos_count] = highlightStrip.css(".highlight_strip_movie").length
    end

    # return the mod data
    mod_data
  end
end