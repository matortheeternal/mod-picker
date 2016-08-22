class WorkshopInfo < ActiveRecord::Base
  include Scrapeable

  # Associations
  belongs_to :mod
  belongs_to :game, :inverse_of => 'workshop_infos'

  # Validations
  validates :game_id, :mod_name, :uploaded_by, :released, presence: true

  def scrape
    # scrape using the Workshop Helper
    mod_data = WorkshopHelper.scrape_mod(id)

    # write the scraping results to the workshop info record
    self.assign_attributes(mod_data)

    # save scraped data
    self.save!
  end
end
