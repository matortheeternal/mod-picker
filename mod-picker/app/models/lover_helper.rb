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
    auth_key = doc.xpath('//form[@id="login"]/input/@value').first.value

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
    RestClient.post(login_url, multipart_data, headers) do |response|
      @cookies = response.cookies
    end
  end

  def self.cookies
    @cookies
  end

  def self.date_joined_format
    'Member Since %d %B %Y'
  end

  def self.scrape_user(id)
    login_if_necessary

    # construct user url
    user_url = 'https://www.loverslab.com/user/' + id

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
    userInfoCell = doc.at_css("#user_info_cell")
    user_data[:username] = userInfoCell.css("h1 span").text.strip
    date_joined_str = userInfoCell.children[2].text.strip
    user_data[:date_joined] = DateTime.parse(date_joined_str, date_joined_format)
    communityStats = doc.at_css(".general_box ul")
    user_data[:posts_count] = communityStats.css("li")[1].css(".row_data").text.gsub(',', '').to_i
    latest_status = doc.at_css("#user_latest_status")
    if latest_status.present?
      user_data[:last_status] = latest_status.css("div")[0].children[0].text.strip
    else
      user_data[:last_status] = nil
    end

    # return user data
    user_data
  end

  def self.retrieve_mod(id)
    login_if_necessary

    # construct mod url
    mod_url = "http://api.loverslab.com/file/#{id}"

    # prepare headers
    headers = {
        :cookies =>  @cookies,
        :"user-agent" => Rails.application.config.user_agent
    }

    # get the mod page
    response = RestClient.get(mod_url, headers)

    # parse the json
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
      "author_id" => nil
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

    # make a game_id field from the game field
    mod_data["game_id"] = Game.find_by(nexus_name: mod_data.delete("game")).id

    # return mod data
    mod_data
  end
end