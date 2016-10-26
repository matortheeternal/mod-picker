class Tag < ActiveRecord::Base
  include Filterable, RecordEnhancements, CounterCache, Reportable, ScopeHelpers, BetterJson

  # SCOPES
  game_scope

  # ASSOCIATIONS
  belongs_to :submitter, :class_name => 'User', :foreign_key => :submitted_by, :inverse_of => 'tags'

  has_many :mod_tags, :inverse_of => 'tag'
  has_many :mods, :through => 'mod_tags', :inverse_of => 'tags'

  has_many :mod_list_tags, :inverse_of => 'tag'
  has_many :mod_lists, :through => 'mod_list_tags', :inverse_of => 'tags'

  # COUNTER CACHE
  counter_cache :mod_tags, column: 'mods_count'
  counter_cache :mod_list_tags, column: 'mod_lists_count'
  counter_cache_on :submitter, conditional: { hidden: false }

  # VALIDATIONS
  validates :game_id, :submitted_by, :text, presence: true
  validates :text, length: {in: 2..32}
  validates :hidden, inclusion: [true, false]
end
