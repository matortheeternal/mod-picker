class AgreementMark < ActiveRecord::Base
  include ScopeHelpers, BetterJson, CounterCache

  # ATTRIBUTES
  self.primary_keys = :correction_id, :submitted_by

  # SCOPES
  ids_scope :correction_id
  value_scope :submitted_by, :alias => 'submitter'

  # ASSOCIATIONS
  belongs_to :submitter, :class_name => 'User', :foreign_key => 'submitted_by', :inverse_of => 'agreement_marks'
  belongs_to :correction, :inverse_of => 'agreement_marks'

  # COUNTER CACHE
  counter_cache_on :submitter
  bool_counter_cache_on :correction, :agree, { true => 'agree_count', false => 'disagree_count' }

  # VALIDATIONS
  validates :correction_id, :submitted_by, presence: true
  validates :agree, inclusion: [true, false]
end
