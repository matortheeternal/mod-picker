class LoverInfo < ActiveRecord::Base
  include Scrapeable, BetterJson

  # ASSOCIATIONS
  belongs_to :mod
  belongs_to :game, :inverse_of => 'lover_infos'

  # VALIDATIONS
  validates :game_id, :mod_name, :uploaded_by, :released, presence: true

  def self.prepare_for_mod(id_string)
    matches = /([0-9]+)\-([0-9a-z]+)/.match(id_string)
    info = LoverInfo.find_or_initialize_by(id: matches[1], url_id: matches[0])
    raise Exceptions::ModExistsError.new(info.mod_id) if info.mod_id
    info
  end

  def scrape
    # retrieve using the Lover Helper
    mod_data = LoverHelper.retrieve_mod(id)

    # write the results to the lover info record
    self.assign_attributes(mod_data)

    # save retrieved mod data
    self.save!
  end

  def url
    "http://www.loverslab.com/files/file/#{url_id}"
  end

  def link_uploader
    bio = UserBio.find_by(lover_username: uploaded_by)
    ModAuthor.add_author(mod_id, bio.user_id) if bio.present? && mod_id.present?
  end

  def can_scrape_statistics?
    true
  end
end
