class LoverInfo < ActiveRecord::Base
  include Scrapeable

  # ASSOCIATIONS
  belongs_to :mod
  belongs_to :game, :inverse_of => 'lover_infos'

  # VALIDATIONS
  validates :game_id, :mod_name, :uploaded_by, :released, presence: true

  def scrape
    # retrieve using the Lover Helper
    mod_data = LoverHelper.retrieve_mod(id)

    # write the results to the lover info record
    self.assign_attributes(mod_data)

    # save retrieved mod data
    self.save!
  end

  def url
    LoverHelper.mod_url(id)
  end

  def notification_json_options(event_type)
    {
        :only => [],
        :include => {
            :mod => { :only => [:id, :name] }
        }
    }
  end

  def link_uploader
    bio = UserBio.find_by(lover_username: uploaded_by)
    if bio.present? && mod_id.present?
      ModAuthor.find_or_create_by(mod_id: mod_id, user_id: bio.user_id)
    end
  end
end
