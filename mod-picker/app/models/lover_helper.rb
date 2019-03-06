require 'nokogiri'
require 'rest-client'

class LoverHelper
  attr_accessor :cookies, :last_request, :last_login

  def self.login_if_necessary
    if @last_login.nil? || @last_login < 1.week.ago ||
       @last_request.nil? || @last_request < 4.hours.ago
      self.login
    end
  end

  def self.login
    # construct index url
    base_url = 'https://www.loverslab.com/'
    index_url = base_url + 'index.php'

    # get the index to get auth key for login
    response = RestClient.get(index_url)
    doc = Nokogiri::HTML(response.body)
    auth_key = doc.xpath('//div[@id="elUserSignIn_internal"]/form/input/@value')[1].value

    # prepare login url
    login_params = '?app=core&module=global&section=login&do=process'
    login_url = index_url + login_params

    # prepare multipart form data
    multipart_data = {
        :auth_key => auth_key,
        :referer => base_url,
        :ips_username => ENV['lover_username'],
        :ips_password => ENV['lover_password'],
        :rememberMe => "1",
        :multipart => true
    }

    # prepare headers
    headers = {
        :cookies => response.cookies,
        :"user-agent" => Rails.application.config.user_agent
    }

    # submit login to the server, the server will return a 302 so we use the block to
    # grab the cookies from the 302 response directly
    @last_request = DateTime.now
    @last_login = DateTime.now
    RestClient.post(login_url, multipart_data, headers) do |r|
      @cookies = r.cookies
    end
  end

  def self.cookies
    @cookies
  end

  def self.scrape_user(id)
    login_if_necessary

    # construct user url
    user_url = 'https://www.loverslab.com/profile/' + id

    # prepare headers
    headers = {
        :cookies =>  @cookies,
        :"user-agent" => Rails.application.config.user_agent
    }

    # get the user page
    response = RestClient.get(user_url, headers)
    @last_request = DateTime.now

    # parse needed data from user page
    doc = Nokogiri::HTML(response.body)
    user_data = {}
    user_data[:username] = doc.at_css(".cProfileHeader_name").css("h1").text.strip
    user_stats = doc.at_css("#elProfileStats")
    date_joined = user_stats.css("time").attr("datetime").value
    user_data[:date_joined] = DateTime.parse(date_joined)
    user_data[:posts_count] = user_stats.css("li")[0].children[1].text.gsub(',', '').to_i
    latest_status = doc.at_css("#elProfileActivityOverview").css("li")[0]
    if latest_status.present?
      user_data[:last_status] = latest_status.css(".ipsType_richText").children[0].text.strip
    else
      user_data[:last_status] = nil
    end

    # return user data
    user_data
  end

  def self.mod_url(id)
    "http://api.loverslab.com/file/#{id}"
  end

  def self.retrieve_mod(id)
    login_if_necessary

    # construct mod url
    url = mod_url(id)
    puts "LoverHelper: Scraping "+url

    # prepare headers
    headers = {
        :cookies =>  @cookies,
        :"user-agent" => Rails.application.config.user_agent
    }

    # get the mod page
    response = RestClient.get(url, headers)
    puts "  Received response #{response.size}"

    # parse the json
    puts "  Parsing response"
    mod_data = JSON.parse(response.body)
    mod_data["submitted"] = DateTime.strptime(mod_data["submitted"].to_s, '%s')
    mod_data["updated"] = DateTime.strptime(mod_data["updated"].to_s, '%s')
    
    # remap the json
    # noinspection RubyStringKeysInHashInspection
    mappings = {
      "name" => "mod_name",
      "author" => "uploaded_by",
      "submitted" => "released",
      "updated" => "updated",
      "followers" => "followers_count",
      "size" => "file_size",
      "version" => "current_version",
      "is_adult" => "has_adult_content",
      "screenshot" => nil,
      "author_id" => nil,
      "category" => nil,
      "tags" => nil
    }
    mod_data.keys.each do |k|
      if mappings.has_key?(k)
        if mappings[k].nil?
          mod_data.delete(k) 
        else
          mod_data[mappings[k]] = mod_data.delete(k)
        end
      end
    end

    # raise exception if uploader is blacklisted
    if BlacklistedAuthor.exists_for?("LoverInfo", mod_data["uploaded_by"])
      raise "the author of this mod has opted out of having their mods listed on Mod Picker"
    end

    # make a game_id field from the game field
    game_name = mod_data.delete('game')
    if game_name == 'other'
      game_name = 'skyrimspecialedition'
    end
    mod_data["game_id"] = Game.find_by(nexus_name: game_name).id

    # return mod data
    puts "  Done."
    mod_data
  end
end