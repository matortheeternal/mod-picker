class ModTag < ActiveRecord::Base
  # ATTRIBUTES
  self.primary_keys = :mod_id, :tag_id

  # ASSOCIATIONS
  belongs_to :mod, :inverse_of => 'mod_tags'
  belongs_to :tag, :inverse_of => 'mod_tags'
  belongs_to :submitter, :class_name => 'User', :inverse_of => 'mod_tags', :foreign_key => 'submitted_by'

  # VALIDATIONS
  validates :mod_id, :tag_id, presence: true
  # can only use a tag on a given mod once
  validates :tag_id, uniqueness: { scope: :mod_id, :message => "This tag already exists on this mod." }

  # CALLBACKS
  after_create :increment_counters
  before_destroy :decrement_counters

  def notification_json_options(event_type)
    {
        :only => [],
        :include => {
            :tag => { :only => [:text] },
            :mod => { :only => [:id, :name] }
        }
    }
  end

  private
    def increment_counters
      self.mod.update_counter(:tags_count, 1)
      self.tag.update_counter(:mods_count, 1)
      self.submitter.update_counter(:mod_tags_count, 1)
    end

    def decrement_counters
      self.mod.update_counter(:tags_count, -1)
      self.tag.update_counter(:mods_count, -1)
      self.submitter.update_counter(:mod_tags_count, -1)
    end
end
