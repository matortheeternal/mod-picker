require 'nokogiri'
require 'rest-client'

class NexusHelper
  attr_accessor :cookies, :last_request, :last_login

  def self.login_if_necessary
    if @last_login.nil? || @last_login < 1.week.ago ||
       @last_request.nil? || @last_request < 4.hours.ago
      self.login
    end
  end

  def self.login
    # construct index url
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

  def self.date_joined_format
    'Member Since %d %B %Y - %I:%M %p'
  end

  def self.scrape_user(id)
    login_if_necessary

    # construct user url
    user_url = 'https://forums.nexusmods.com/index.php?showuser=' + id

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
    user_info = doc.at_css("#user_info_cell")
    user_data[:username] = user_info.css("h1 span").text.strip
    date_joined_str = user_info.children[2].text.strip
    user_data[:date_joined] = DateTime.parse(date_joined_str, date_joined_format)
    community_stats = doc.at_css(".general_box ul")
    user_data[:posts_count] = community_stats.css("li")[1].css(".row_data").text.gsub(',', '').to_i
    latest_status = doc.at_css("#user_latest_status")
    if latest_status.present?
      user_data[:last_status] = latest_status.css("div")[0].children[0].text.strip
    else
      user_data[:last_status] = nil
    end

    # return user data
    user_data
  end

  def self.date_format
    '%d/%m/%Y - %I:%M%p'
  end

  def self.rd_date_format
    '%Y-%m-%d %H:%M'
  end

  # use this method if the data is sometimes not present on the page
  def self.try_parse(doc, selector, default)
    begin
      doc.at_css(selector).text
    rescue
      default
    end
  end

  def self.mod_url(game_name, id)
    "http://www.nexusmods.com/#{game_name}/mods/#{id}"
  end

  def self.mod_api_url(game_name, id)
    "http://api.nexusmods.com/v1/games/#{game_name}/mods/#{id}.json"
  end

  def self.get_rd_stat(doc, classname)
    doc.at_css(".stat-#{classname}").css('.stat')[0].text.gsub(',', '')
  end

  def self.get_rd_info(doc, index)
    doc.at_css('#fileinfo').css('.sideitem')[index]
  end

  def self.get_rd_tab_stat(doc, selector)
    begin
      doc.at_css(selector).text.to_i
    rescue
      0
    end
  end

  def self.scrape_rd_mod(doc)
    # raise an exception if we got a 404 page
    page_title = doc.at_css('#pagetitle')
    raise "Mod not found" if page_title.nil?

    # scrape basic data
    mod_data = {}
    mod_data[:last_scraped] = DateTime.now
    mod_data[:mod_name] = page_title.css('h1')[0].text
    mod_data[:current_version] = get_rd_stat(doc, 'version')
    mod_data[:uploaded_by] = get_rd_info(doc, 3).children[3].text
    mod_data[:authors] = get_rd_info(doc, 2).children[2].text.strip

    # raise exception if uploader is blacklisted
    if BlacklistedAuthor.exists_for?('NexusInfo', mod_data[:uploaded_by])
      raise 'the author of this mod has opted out of having their mods on Mod Picker'
    end

    # scrape dates
    date_added_str = get_rd_info(doc, 1).children[3].attr('datetime')
    mod_data[:released] = DateTime.parse(date_added_str, rd_date_format)
    date_updated_str = get_rd_info(doc, 0).children[3].attr('datetime')
    mod_data[:updated] = DateTime.parse(date_updated_str, rd_date_format)

    # scrape statistics
    mod_data[:has_stats] = Rails.application.config.scrape_nexus_statistics
    if Rails.application.config.scrape_nexus_statistics
      puts '  Parsing statistics'
      mod_data[:endorsements] = get_rd_stat(doc, 'endorsements')
      mod_data[:unique_downloads] = get_rd_stat(doc, 'uniquedls')
      mod_data[:downloads] = get_rd_stat(doc, 'totaldls')
      mod_data[:views] = get_rd_stat(doc, 'totalviews')

      # scrape nexus category
      breadcrumbs = doc.at_css('#breadcrumb').css('li')
      catlink = breadcrumbs[breadcrumbs.length - 2].children[1].attr('href')
      mod_data[:nexus_category] = /categories\/([0-9]*)/.match(catlink).captures[0].to_i

      # scrape counts
      mod_data[:files_count] = get_rd_tab_stat(doc, '#mod-page-tab-files .alert')
      mod_data[:images_count] = get_rd_tab_stat(doc, '#mod-page-tab-images .alert')
      mod_data[:bugs_count] = get_rd_tab_stat(doc, '#mod-page-tab-bugs .alert')
      mod_data[:discussions_count] = get_rd_tab_stat(doc, '#mod-page-tab-forums .alert')
      mod_data[:articles_count] = get_rd_tab_stat(doc, '#mod-page-tab-articles .alert')
      mod_data[:posts_count] = get_rd_tab_stat(doc, '#mod-page-tab-posts .alert')
      mod_data[:videos_count] = get_rd_tab_stat(doc, '#mod-page-tab-videos .alert')
    end

    # return the mod data
    puts '  Done.'
    mod_data
  end

  def self.retrieve_mod(game_name, id)
    url = mod_api_url(game_name, id)
    puts 'NexusHelper: Scraping ' + url

    # prepare headers
    headers = {
        :accept => 'application/json',
        :apikey => ENV['nexus_mods_api_key'],
        :'user-agent' => Rails.application.config.user_agent
    }

    # get the mod page
    response = RestClient.get(url, headers)
    puts "  Recieved response #{response.size}"

    # parse JSON
    puts '  Parsing response'
    api_data = JSON.parse(response.body)

    # return mod data object
    {
        last_scraped: DateTime.now,
        mod_name: api_data["name"],
        released: DateTime.strptime(api_data["created_timestamp"].to_s, '%s'),
        updated: DateTime.strptime(api_data["updated_timestamp"].to_s, '%s'),
        current_version: api_data["version"],
        authors: api_data["author"],
        uploaded_by: api_data["uploaded_by"],
        has_adult_content: api_data["contains_adult_content"],
        has_stats: false,
        nexus_category: api_data["category_id"]
    }
  end

  # TODO: Scraping logic for has_adult_content
  def self.scrape_mod(game_name, id)
    login_if_necessary

    # construct mod url
    url = mod_url(game_name, id)
    puts 'NexusHelper: Scraping '+url

    # prepare headers
    headers = {
        :cookies =>  @cookies,
        :'user-agent' => Rails.application.config.user_agent
    }

    # get the mod page
    response = RestClient.get(url, headers)
    puts "  Recieved response #{response.size}"
    @last_request = DateTime.now

    # parse needed data from the mod page
    puts '  Parsing response'
    doc = Nokogiri::HTML(response.body)

    # handle redesign
    return scrape_rd_mod(doc) if doc.at_css('.site-nexusmods-b').present?

    # raise an exception if we got a 404 page
    header_node = doc.at_css('#Header')
    raise header_node.text if header_node.present?

    # scrape basic data
    mod_data = {}
    mod_data[:last_scraped] = DateTime.now
    mod_data[:mod_name] = doc.at_css('.header-name').text
    mod_data[:current_version] = doc.at_css('.file-version strong').text
    mod_data[:uploaded_by] = doc.at_css('.uploader a').text
    mod_data[:authors] = doc.at_css('.header-author strong').text

    # raise exception if uploader is blacklisted
    if BlacklistedAuthor.exists_for?('NexusInfo', mod_data[:uploaded_by])
      raise 'the author of this mod has opted out of having their mods on Mod Picker'
    end

    # scrape dates
    dates = doc.at_css('.header-dates').css('div')
    date_added_str = dates[0].children[1].text.strip
    mod_data[:released] = DateTime.parse(date_added_str, date_format)
    date_updated_str = dates[1].children[1].text.strip
    mod_data[:updated] = DateTime.parse(date_updated_str, date_format)

    # scrape statistics
    mod_data[:has_stats] = Rails.application.config.scrape_nexus_statistics
    if Rails.application.config.scrape_nexus_statistics
      puts '  Parsing statistics'
      mod_data[:endorsements] = doc.at_css('#span_endors_number').text.gsub(',', '')
      mod_data[:unique_downloads] = doc.at_css('.file-unique-dls strong').text.gsub(',', '')
      mod_data[:downloads] = doc.at_css('.file-total-dls strong').text.gsub(',', '')
      mod_data[:views] = doc.at_css('.file-total-views strong').text.gsub(',', '')

      # scrape nexus category
      catlink = doc.at_css('.header-cat').css('a/@href')[1].text
      mod_data[:nexus_category] = /src_cat=([0-9]*)/.match(catlink).captures[0].to_i

      # scrape counts
      mod_data[:files_count] = try_parse(doc, '.tab-files strong', '0').to_i
      mod_data[:images_count] = try_parse(doc, '.tab-images strong', '0').to_i
      mod_date[:bugs_count] = try_parse(doc, '.tab-bugs strong', '0').to_i
      mod_data[:discussions_count] = try_parse(doc, '.tab-discussion strong', '0').to_i
      mod_data[:articles_count] = try_parse(doc, '.tab-articles strong', '0').to_i
      mod_data[:posts_count] = try_parse(doc, '.tab-comments strong', '0').to_i
      mod_data[:videos_count] = try_parse(doc, '.tab-videos', '0').to_i
    end

    # return the mod data
    puts '  Done.'
    mod_data
  end
end