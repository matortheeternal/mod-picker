class Correction < ActiveRecord::Base
  include Filterable, Sortable, RecordEnhancements, Reportable, ScopeHelpers

  enum status: [:open, :passed, :failed, :closed]
  enum mod_status: [:good, :outdated, :unstable]

  # SCOPES
  include_scope :hidden
  include_scope :has_adult_content, :alias => 'include_adult'
  visible_scope
  search_scope :title, :text_body, :combine => true
  user_scope :submitter
  enum_scope :status
  enum_scope :mod_status
  user_scope :submitter
  polymorphic_scope :correctable

  # ASSOCIATIONS
  belongs_to :game, :inverse_of => 'corrections'
  belongs_to :submitter, :class_name => 'User', :foreign_key => 'submitted_by', :inverse_of => 'corrections'
  belongs_to :editor, :class_name => 'User', :foreign_key => 'edited_by'

  has_many :agreement_marks, :inverse_of => 'correction'
  has_many :comments, -> { where(parent_id: nil) }, :as => 'commentable'
  
  belongs_to :correctable, :polymorphic => true

  # number of corrections per page on the corrections index
  self.per_page = 25

  # Validations
  validates :game_id, :submitted_by, :correctable_id, :correctable_type, :text_body, presence: true
  validates :text_body, length: { in: 64..16384 }

  # Callbacks
  after_create :increment_counters
  before_save :set_dates
  after_save :recompute_correctable_standing
  after_destroy :decrement_counters, :recompute_correctable_standing

  def self.index_json(collection)
    collection.as_json({
        :include => {
            :submitter => {
                :only => [:id, :username, :role, :title],
                :include => {
                    :reputation => {:only => [:overall]}
                },
                :methods => :avatar
            },
            :correctable => {
                :only => [:id, :name],
                :include => {
                    :submitter => {
                        :only => [:id, :username]
                    }
                },
                :methods => :mods
            },
        }
    })
  end

  def as_json(options={})
    if JsonHelpers.json_options_empty(options)
      default_options = {
          :include => {
              :submitter => {
                  :only => [:id, :username, :role, :title],
                  :include => {
                      :reputation => {:only => [:overall]}
                  },
                  :methods => :avatar
              }
          }
      }
      super(options.merge(default_options))
    else
      super(options)
    end
  end

  def recompute_correctable_standing
    if self.correctable.respond_to?(:standing)
      self.correctable.compute_standing
      self.correctable.update_column(:standing, self.correctable.standing)
    end
  end

  private
    def set_dates
      if self.submitted.nil?
        self.submitted = DateTime.now
      else
        self.edited = DateTime.now
      end
    end

    def increment_counters
      self.correctable.update_counter(:corrections_count, 1)
      self.submitter.update_counter(:corrections_count, 1)
    end

    def decrement_counters
      self.correctable.update_counter(:corrections_count, -1)
      self.submitter.update_counter(:corrections_count, -1)
    end 
end
