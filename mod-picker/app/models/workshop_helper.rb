require 'nokogiri'
require 'rest-client'

class WorkshopHelper
  def self.scrape_user(id)
    # construct user url
    # ex. http://steamcommunity.com/id/Naricissu/
    user_url = 'http://steamcommunity.com/id/' + id

    # prepare headers
    headers = {
        :cookies =>  @cookies,
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
      comment_body = comment.at_css("div.commentthread_comment_text").text.strip

      puts "Author url ==" + author_url
      puts "Comment body ==" + comment_body

      # Case insensitive comparison of comment author's profile urls
      if author_url.casecmp(user_url) == 0
        user_data[:matched_comment] = comment_body
      end
    end

    # return user data
    user_data
  end
end