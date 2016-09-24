class WorkshopInfo < ActiveRecord::Base
  include Scrapeable

  # ASSOCIATIONS
  belongs_to :mod
  belongs_to :game, :inverse_of => 'workshop_infos'

  # VALIDATIONS
  validates :game_id, :mod_name, :uploaded_by, :released, presence: true

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

  def notification_json_options(event_type)
    {
        :only => [],
        :include => {
            :mod => { :only => [:id, :name] }
        }
    }
  end
end
