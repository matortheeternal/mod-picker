class ModListTag < ActiveRecord::Base
  include Trackable

  # ATTRIBUTES
  attr_accessor :removed_by

  # EVENT TRACKING
  track :added, :removed

  # NOTIFICATION SUBSCRIPTIONS
  subscribe :mod_list_submitter, to: [:added, :removed]
  subscribe :submitter, to: [:removed]

  # ASSOCIATIONS
  belongs_to :mod_list, :inverse_of => 'mod_list_tags'
  belongs_to :tag, :inverse_of => 'mod_list_tags'
  belongs_to :submitter, :class_name => 'User', :inverse_of => 'mod_list_tags', :foreign_key => 'submitted_by'
  has_one :mod_list_submitter, :through => :mod_list, :source => 'submitter'

  # VALIDATIONS
  validates :mod_list_id, :tag_id, :submitted_by, presence: true
  # can only use a tag on a given mod list once
  validates :tag_id, uniqueness: { scope: :mod_list_id, :message => "This tag already exists on this mod list." }

  # CALLBACKS
  after_create :increment_counters
  before_destroy :decrement_counters

  def notification_json_options(event_type)
    {
        :only => [],
        :include => {
            :tag => { :only => [:text] },
            :mod_list => { :only => [:id, :name] }
        }
    }
  end

  private
    def increment_counters
      self.mod_list.update_counter(:tags_count, 1)
      self.tag.update_counter(:mod_lists_count, 1)
      self.submitter.update_counter(:mod_list_tags_count, 1)
    end

    def decrement_counters
      self.mod_list.update_counter(:tags_count, -1)
      self.tag.update_counter(:mod_lists_count, -1)
      self.submitter.update_counter(:mod_list_tags_count, -1)
    end
end
