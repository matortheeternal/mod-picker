class HelpfulMark < ActiveRecord::Base
  include Filterable, ScopeHelpers, BetterJson, Dateable, CounterCache

  # ATTRIBUTES
  self.primary_keys = :submitted_by, :helpfulable_id, :helpfulable_type

  # DATE COLUMNS
  date_column :submitted

  # SCOPES
  value_scope :submitted_by, :alias => 'submitter'
  value_scope :helpful
  polymorphic_scope :helpfulable

  # ASSOCIATIONS
  belongs_to :helpfulable, :polymorphic => true
  belongs_to :submitter, :class_name => 'User', :foreign_key => 'submitted_by', :inverse_of => 'helpful_marks'

  # COUNTER CACHE
  counter_cache_on :submitter
  bool_counter_cache_on :helpfulable, :helpful, { true => :helpful, false => :not_helpful }

  # VALIDATIONS
  validates :submitted_by, :helpfulable_id, :helpfulable_type, presence: true

  validates :helpful, inclusion: {
    in: [true, false],
    message: "must be true or false"
  }

  validates :helpfulable_type, inclusion: {
    in: ["CompatibilityNote", "InstallOrderNote", "LoadOrderNote", "Review"],
    message: "does not support helpful marks"
  }

  # CALLBACKS
  after_create :update_helpfulable_reputation
  before_destroy :update_helpfulable_reputation

  private
    def update_helpfulable_reputation
      helpfulable.compute_reputation!
    end
end
