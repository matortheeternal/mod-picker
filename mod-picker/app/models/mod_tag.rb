class ModTag < ActiveRecord::Base
  include Trackable, BetterJson, CounterCache

  # EVENT TRACKING
  track :added

  # NOTIFICATION SUBSCRIPTIONS
  subscribe :mod_author_users, to: [:added]

  # ASSOCIATIONS
  belongs_to :mod, :inverse_of => 'mod_tags'
  belongs_to :tag, :inverse_of => 'mod_tags'
  belongs_to :submitter, :class_name => 'User', :inverse_of => 'mod_tags', :foreign_key => 'submitted_by'

  has_many :mod_author_users, :through => :mod, :source => 'author_users'

  # COUNTER CACHE
  counter_cache_on :mod, column: 'tags_count'
  counter_cache_on :tag, column: 'mods_count'
  counter_cache_on :submitter

  # VALIDATIONS
  validates :mod_id, :tag_id, presence: true
  # can only use a tag on a given mod once
  validates :tag_id, uniqueness: { scope: :mod_id, :message => "This tag already exists on this mod." }
end
