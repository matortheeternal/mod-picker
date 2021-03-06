class Correction < ActiveRecord::Base
  include Filterable, Sortable, RecordEnhancements, CounterCache, Reportable, ScopeHelpers, Searchable, Trackable, BetterJson, Dateable

  # ATTRIBUTES
  enum status: [:open, :passed, :failed, :closed]
  enum mod_status: [:good, :outdated, :unstable]
  self.per_page = 25

  # DATE COLUMNS
  date_column :submitted, :edited

  # EVENT TRACKING
  track :added, :hidden, :status

  # NOTIFICATION SUBSCRIPTIONS
  subscribe :submitter, to: [:status, :action_soon, :hidden, :unhidden]
  subscribe :commenters, to: [:status]
  subscribe :mod_author_users, to: [:added, :status]

  # SCOPES
  hash_scope :hidden, alias: 'hidden'
  hash_scope :adult, alias: 'adult', column: 'has_adult_content'
  include_scope :hidden
  game_scope
  visible_scope
  enum_scope :status
  enum_scope :mod_status
  polymorphic_scope :correctable
  range_scope :agree_count, :disagree_count
  counter_scope :comments_count
  range_scope :overall, :association => 'submitter_reputation', :table => 'user_reputations', :alias => 'reputation'
  date_scope :submitted, :edited

  # ASSOCIATIONS
  belongs_to :game, :inverse_of => 'corrections'
  belongs_to :submitter, :class_name => 'User', :foreign_key => 'submitted_by', :inverse_of => 'corrections'
  belongs_to :editor, :class_name => 'User', :foreign_key => 'edited_by'

  has_one :submitter_reputation, :class_name => 'UserReputation', :through => 'submitter', :source => 'reputation'

  has_many :agreement_marks, :inverse_of => 'correction'
  has_many :comments, -> { where(parent_id: nil) }, :as => 'commentable'
  has_many :commenters, :class_name => 'User', :through => :comments, :source => 'submitter', :foreign_key => 'submitted_by'

  belongs_to :correctable, :polymorphic => true

  # COUNTER CACHE
  bool_counter_cache :agreement_marks, :agree, { true => :agree, false => :disagree }
  counter_cache :comments, conditional: { hidden: false, commentable_type: 'Correction' }
  counter_cache_on :correctable, :submitter, conditional: { hidden: false }

  # VALIDATIONS
  validates :game_id, :submitted_by, :correctable_id, :correctable_type, :text_body, presence: true
  validates :text_body, length: { in: 64..16384 }

  # CALLBACKS
  after_create :schedule_close
  before_save :set_adult
  after_save :recompute_correctable_standing
  after_destroy :recompute_correctable_standing

  # CONSTANTS
  MINIMUM_VOTES = 4

  # METHODS
  def self.close(id)
    correction = Correction.find(id)
    if correction.status == "open"
      correction.passed? ? correction.pass : correction.fail
      correction.save
    end
  end

  def pass
    self.status = "passed"
    correctable.correction_passed(self)
  end

  def fail
    self.status = "failed"
  end

  def has_minimum_votes?
    agree_count + disagree_count >= MINIMUM_VOTES
  end

  def passed?
    has_minimum_votes? && agree_count > disagree_count
  end

  def mod_author_users
    if correctable_type == "Mod"
      correctable.author_users
    else
      []
    end
  end

  def self.update_adult(model, ids)
    Correction.where(correctable_type: model.model_name.to_s, id: ids).joins("INNER JOIN #{model.table_name} ON #{model.table_name}.id = corrections.correctable_id").update_all("corrections.has_adult_content = #{model.table_name}.has_adult_content")
    Comment.commentables("Correction", ids).joins("INNER JOIN corrections ON corrections.id = comments.commentable_id").update_all("comments.has_adult_content = corrections.has_adult_content")
  end

  def recompute_correctable_standing
    if correctable.respond_to?(:standing)
      correctable.compute_standing
      correctable.update_column(:standing, correctable.standing)
    end
  end

  private
    def set_adult
      self.has_adult_content = correctable.has_adult_content
      true
    end

    def schedule_close
      Correction.delay_for(1.week).close(id)
    end
end
