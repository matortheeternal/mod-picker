class LoverInfo < ActiveRecord::Base
  include Scrapeable

  # Associations
  belongs_to :mod
  belongs_to :game, :inverse_of => 'lover_infos'

  # validations
  validates :game_id, :mod_name, :uploaded_by, :released, presence: true

  def scrape
    # retrieve using the Lover Helper
    mod_data = LoverHelper.retrieve_mod(id)

    # write the results to the lover info record
    self.assign_attributes(mod_data)

    # save retrieved mod data
    self.save!
  end
end
