class WorkshopInfo < ActiveRecord::Base
  include Scrapeable, BetterJson

  # ASSOCIATIONS
  belongs_to :mod
  belongs_to :game, :inverse_of => 'workshop_infos'

  # VALIDATIONS
  validates :game_id, :mod_name, :uploaded_by, :released, presence: true

  def self.prepare_for_mod(id)
    info = WorkshopInfo.find_or_initialize_by(id: id)
    raise Exceptions::ModExistsError.new(info.mod_id) if info.mod_id
    info
  end

  def scrape
    # scrape using the Workshop Helper
    mod_data = WorkshopHelper.scrape_mod(id)

    # write the scraping results to the workshop info record
    self.assign_attributes(mod_data)

    # save scraped data
    self.save!
  end

  def url
    WorkshopHelper.mod_url(id)
  end

  def link_uploader
    bio = UserBio.find_by(workshop_username: uploaded_by)
    if bio.present? && mod_id.present?
      ModAuthor.find_or_create_by(mod_id: mod_id, user_id: bio.user_id)
    end
  end

  def self.can_scrape_statistics?
    Rails.application.config.scrape_workshop_statistics
  end
end
