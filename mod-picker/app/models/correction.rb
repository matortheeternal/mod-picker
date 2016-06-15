class Correction < ActiveRecord::Base
  include Filterable, RecordEnhancements

  scope :by, -> (id) { where(submitted_by: id) }

  enum status: [:open, :passed, :failed]
  enum mod_status: [:good, :outdated, :unstable]

  belongs_to :game, :inverse_of => 'corrections'
  belongs_to :submitter, :class_name => 'User', :foreign_key => 'submitted_by', :inverse_of => 'corrections'
  belongs_to :editor, :class_name => 'User', :foreign_key => 'edited_by'

  has_many :agreement_marks, :inverse_of => 'correction'
  has_many :comments, -> { where(parent_id: nil) }, :as => 'commentable'
  
  belongs_to :correctable, :polymorphic => true
  has_one :base_report, :as => 'reportable'

  # Validations
  validates :text_body, length: { in: 64..16384 }
  validates :correctable_id, :correctable_type, presence: true

  # Callbacks
  after_create :increment_counters
  before_save :set_dates
  before_destroy :decrement_counters

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
