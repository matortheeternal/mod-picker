require 'nokogiri'
require 'rest-client'

class WorkshopHelper
  def self.scrape_user(id)
    # vanityURL:        https://steamcommunity.com/id/Naricissu/myworkshopfiles
    # Steam base64 id:  https://steamcommunity.com/profiles/76561197996859192/myworkshopfiles
    
    # Convert to string if not already a string
    id = id.to_s unless id.is_a?(String)

    # Check if id is vanityURL or steam base64 id
    if id =~ /^7656119[0-9]{10}$/i
      user_url = "https://steamcommunity.com/profiles/" + id
    else
      user_url = "https://steamcommunity.com/id/" + id
    end

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

      # Case insensitive comparison of comment author's profile urls
      if author_url.casecmp(user_url) == 0
        user_data[:matched_comment] = comment_body
        user_data[:username] = author_display_name

        # return user data
        # user_data is returned here so first comment who's author
        # matches the given url is returned for comparison to the verification key
        return user_data
      end
    end

  end

  def self.scrape_workshop_stats(id)
    # vanityURL:        https://steamcommunity.com/id/Naricissu/myworkshopfiles
    # Steam base64 id:  https://steamcommunity.com/profiles/76561197996859192/myworkshopfiles
    
    # Convert to string if not already a string
    id = id.to_s unless id.is_a?(String)

    # Check if id is vanityURL or steam base64 id
    if id =~ /^7656119[0-9]{10}$/i
      user_url = "https://steamcommunity.com/profiles/" + id + "/myworkshopfiles"
    else
      user_url = "https://steamcommunity.com/id/" + id + "/myworkshopfiles"
    end
    

    # prepare headers
    headers = {
        :"user-agent" => Rails.application.config.user_agent
    }

    # get the user page
    response = RestClient.get(user_url, headers)
    @last_request = DateTime.now

    # parse needed data from user page
    doc = Nokogiri::HTML(response.body)
    user_data = {}

    # .css searches for every occurence of the accessor
    # .at_css searches for the first occurence
    
    # Checks if an error message from steam indicating the user profile was found or not
    # If error is missing, user is found
    # If error is present, user is not found
    user_found = doc.at_css("div#message").blank?

    # Checks if response code is good and user is found before scraping for stats
    if response.code == 200 && user_found
      numOfEntriesText = doc.at_css("div.workshopBrowsePagingInfo")

      # Checks if number of workshop items div is empty or not
      # If blank that means the user has no items uploaded
      # workshop items count
      if numOfEntriesText.blank?
        user_data[:submissions_count] = 0
      else
        numOfEntries = numOfEntriesText.text =~ /(?<=[0-9] of ).[0-9]+(?= entries)/
        # puts "num of entries = " + numOfEntries.inspect
        user_data[:submissions_count] = numOfEntries.inspect
      end

      # username
      user_data[:username] = doc.at_css("span#HeaderUserInfoName a").text

      # follower stats are always available even if 0
      # Follower count
      user_data[:followers_count] = doc.at_css("div.followStat").text

    elsif !user_found 
      puts "Error finding user profile"
    elsif response.code != 200
      puts "Error fetching user stats"
    end

    

    # return user data
    user_data
  end

  def self.workshop_date_format
    '%b %d, %Y @ %I:%M%p'
  end

  def self.game_id_from_app_id(app_id)
    Game.pluck(:id, :steam_app_ids).each do |id, app_ids|
      if app_ids && app_ids.split(',').include?(app_id)
        return id
      end
    end
  end

  def self.mod_url(id)
    "http://steamcommunity.com/sharedfiles/filedetails/#{id}"
  end

  def self.scrape_mod(id)
    # construct mod url
    url = mod_url(id)
    puts "WorkshopHelper: Scraping "+url

    # prepare headers
    headers = {
        :"user-agent" => Rails.application.config.user_agent
    }

    # get the mod page
    response = RestClient.get(url, headers)
    puts "  Recieved response #{response.size}"

    # parse needed data from the mod page
    puts "  Parsing response..."
    doc = Nokogiri::HTML(response.body)
    mod_data = {}

    # scrape basic data
    mod_data[:last_scraped] = DateTime.now
    mod_data[:mod_name] = doc.at_css(".workshopItemTitle").text
    mod_data[:uploaded_by] = doc.at_css(".creatorsBlock .friendBlockContent").children[0].text.strip
    app_id = doc.at_css("#ig_bottom .breadcrumbs").css('a/@href')[0].text.split('/').last
    mod_data[:game_id] = game_id_from_app_id(app_id)

    # raise exception if uploader is blacklisted
    if BlacklistedAuthor.exists_for?("WorkshopInfo", mod_data["uploaded_by"])
      raise "the author of this mod has opted out of having their mods listed on Mod Picker"
    end

    # scrape dates
    # <.detailsStatsContainerRight>
    stats = doc.at_css(".detailsStatsContainerRight").css(".detailsStatRight")
    date_submitted_str = stats[1].text.strip
    mod_data[:released] = DateTime.parse(date_submitted_str, workshop_date_format)
    date_updated_str = stats[2].text.strip
    mod_data[:updated] = DateTime.parse(date_updated_str, workshop_date_format)

    # scrape statistics
    mod_data[:has_stats] = Rails.application.config.scrape_workshop_statistics
    if Rails.application.config.scrape_workshop_statistics
      puts "  Parsing statistics"
      mod_data[:file_size] = stats[0].text.gsub(' MB', '').to_f * 1024 * 1024
      # <.sectionTabs>
      sectionTabs = doc.at_css(".sectionTabs").css(".sectionTab")
      mod_data[:discussions_count] = sectionTabs[1].css(".tabCount").text.to_i
      mod_data[:posts_count] = sectionTabs[2].css(".tabCount").text.to_i
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
    puts "  Done."
    mod_data
  end
end