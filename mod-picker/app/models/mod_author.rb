class ModAuthor < ActiveRecord::Base
  enum role: [:author, :contributor, :curator]

  belongs_to :mod, :inverse_of => 'mod_authors'
  belongs_to :user, :foreign_key => 'user_id', :inverse_of => 'mod_authors'

  # VALIDATIONS
  validates :mod_id, :user_id, presence: true

  # CALLBACKS
  after_create :increment_counters
  before_destroy :decrement_counters

  def self.link_author(model, user_id, username)
    infos = model.where(uploaded_by: username)

    infos.each do |info|
      ModAuthor.find_or_create_by(mod_id: info.mod_id, user_id: user_id) if info.mod_id.present?
    end
  end

  def notification_json_options(event_type)
    {
        :only => [:role],
        :include => {
            :user => { :only => [:id, :username] },
            :mod => { :only => [:id, :name] }
        }
    }
  end

  private
    def decrement_counters
      self.user.update_counter(:authored_mods_count, -1)
    end

    def increment_counters
      self.user.update_counter(:authored_mods_count, 1)
    end
end
