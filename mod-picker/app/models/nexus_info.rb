require 'nokogiri'
require 'open-uri'

class NexusInfo < ActiveRecord::Base
  belongs_to :mod
  belongs_to :game, :inverse_of => 'nexus_infos'

  validates_presence_of :id, :game_id

  def nexus_mods_url
    "http://www.nexusmods.com/#{game.nexus_name}/mods/#{id}"
  end

  def scrape
    doc = Nokogiri::HTML(open(nexus_mods_url))
    modName = doc.at_css(".header-name").text
    currentVersion = doc.at_css(".file_version").text
    self.authors = doc.at_css(".header-author").text
    self.endorsements = doc.at_css("#span_endors_number").text
    self.unique_downloads = doc.at_css(".file-unique-dls").text
    self.total_downloads = doc.at_css(".file-total-dls").text
    self.views = doc.at_css(".file-total-views").text
    self.uploaded_by = doc.at_css(".uploader").text
    # TODO: Date added, date updated, nexus category, isUtility
    # TODO: Create associated mod and mod version records
  end
end
