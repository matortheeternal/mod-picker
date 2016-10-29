class ModListTag < ActiveRecord::Base
  include Trackable, BetterJson, CounterCache

  # EVENT TRACKING
  track :added

  # NOTIFICATION SUBSCRIPTIONS
  subscribe :mod_list_submitter, to: [:added]

  # ASSOCIATIONS
  belongs_to :mod_list, :inverse_of => 'mod_list_tags'
  belongs_to :tag, :inverse_of => 'mod_list_tags'
  belongs_to :submitter, :class_name => 'User', :inverse_of => 'mod_list_tags', :foreign_key => 'submitted_by'
  has_one :mod_list_submitter, :through => :mod_list, :source => 'submitter'

  # COUNTER CACHE
  counter_cache_on :mod_list, column: 'tags_count'
  counter_cache_on :tag, column: 'mod_lists_count'
  counter_cache_on :submitter

  # VALIDATIONS
  validates :mod_list_id, :tag_id, :submitted_by, presence: true
  # can only use a tag on a given mod list once
  validates :tag_id, uniqueness: { scope: :mod_list_id, :message => "This tag already exists on this mod list." }
end
