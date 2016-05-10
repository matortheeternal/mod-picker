require 'nokogiri'
require 'rest-client'

class NexusHelper
  attr_accessor :cookies

  def self.login
    base_url = 'https://forums.nexusmods.com/'
    index_url = base_url + 'index.php'
    response = RestClient.get(index_url)
    doc = Nokogiri::HTML(response.body)
    auth_key = doc.xpath('//form[@id="login"]/input/@value').first.value

    login_params = '?app=core&module=global&section=login&do=process'
    login_url = index_url + login_params
    multipart_data = {
        :auth_key => auth_key,
        :referer => base_url,
        :ips_username => ENV['nexus_username'],
        :ips_password => ENV['nexus_password'],
        :rememberMe => "1",
        :multipart => true
    }
    headers = {
        :'Accept' => "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
        :'Accept-Language' => "en-US,en;q=0.8",
        :'Cache-Control' => "max-age=0",
        :'Connection' => "keep-alive",
        :cookies => {
            :session_id => response.cookies['session_id'],
            :_ga => "GA1.2.1455726809.1462910178",
            :_gat => "1"
        },
        :'Host' => "forums.nexusmods.com",
        :'Origin' => "https://forums.nexusmods.com",
        :'Referer' => base_url,
        :'Upgrade-Insecure-Requests' => "1",
        :'User-Agent' => 'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/47.0.2526.73 Safari/537.36'
    }
    login_response = RestClient.post(login_url, multipart_data, headers) { |response, request, result|
      response
    }
    @cookies = login_response.cookies
  end

  def self.cookies
    @cookies
  end

  def self.scrape_user(id)
    base_url = 'https://forums.nexusmods.com/'
    user_url = 'https://forums.nexusmods.com/index.php?/user/' + id
    headers = {
        :'Accept' => "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
        :'Accept-Language' => "en-US,en;q=0.8",
        :'Connection' => "keep-alive",
        :cookies =>  @cookies.merge({
            :_ga => "GA1.2.1455726809.1462910178",
            :_gat => "1"
        }),
        :'Host' => "forums.nexusmods.com",
        :'Referer' => base_url,
        :'Upgrade-Insecure-Requests' => "1",
        :'User-Agent' => 'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/47.0.2526.73 Safari/537.36'
    }
    byebug
    response = RestClient.get(user_url, headers) { |response, request, result| response}

    # parse the stuff
    doc = Nokogiri::HTML(response.body)
    user_stuff = {id: id}
    userInfoCell = doc.at_css("#user_info_cell")
    user_stuff[:username] = userInfoCell.css("h1 span").text.strip
    user_stuff[:date_joined] = userInfoCell.children[2].text.strip
    communityStats = doc.at_css(".general_box ul")
    user_stuff[:activePosts] = communityStats.css("li")[1].css(".row_data").text.strip
    user_stuff[:lastStatus] = doc.at_css("#user_latest_status").css("div")[0].children[0].text.strip

    # return user stuff
    user_stuff
  end
end