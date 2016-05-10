require 'nokogiri'
require 'rest-client'

class NexusHelper
  attr_accessor :cookies

  def self.login
    # construct url
    base_url = 'https://forums.nexusmods.com/'
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
        :ips_username => ENV['nexus_username'],
        :ips_password => ENV['nexus_password'],
        :rememberMe => "1",
        :multipart => true
    }

    # prepare headers
    headers = {
        :cookies => response.cookies
    }

    # submit login to the server, the server will return a 302 so we use the block to
    # grab the cookies from the 302 response directly
    RestClient.post(login_url, multipart_data, headers) do |response|
      @cookies = response.cookies
    end
  end

  def self.cookies
    @cookies
  end

  def self.scrape_user(id)
    # construct url
    base_url = 'https://forums.nexusmods.com/'
    user_url = 'https://forums.nexusmods.com/index.php?/user/' + id

    # prepare headers
    headers = {
        :cookies =>  @cookies
    }

    # get the user page
    response = RestClient.get(user_url, headers)

    # parse needed data from user page
    doc = Nokogiri::HTML(response.body)
    user_data = {id: id}
    userInfoCell = doc.at_css("#user_info_cell")
    user_data[:username] = userInfoCell.css("h1 span").text.strip
    user_data[:date_joined] = userInfoCell.children[2].text.strip
    communityStats = doc.at_css(".general_box ul")
    user_data[:posts_count] = communityStats.css("li")[1].css(".row_data").text.strip
    user_data[:last_status] = doc.at_css("#user_latest_status").css("div")[0].children[0].text.strip

    # return user data
    user_data
  end
end