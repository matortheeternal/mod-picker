class IncorrectNote < ActiveRecord::Base
  include Filterable

  # Before/after actions for counter_caches
  after_create :increment_counter_caches
  before_destroy :decrement_counter_caches

  after_initialize :init   

  scope :by, -> (id) { where(submitted_by: id) }

  belongs_to :user, :foreign_key => 'submitted_by', :inverse_of => 'incorrect_notes'
  has_many :agreement_marks, :inverse_of => 'incorrect_note'
  has_many :comments, :as => 'commentable'
  
  belongs_to :correctable, :polymorphic => true
  has_one :base_report, :as => 'reportable'

  # Validations
  validates :text_body, length: { in: 64..16384 }
  validates :correctable_id, :correctable_type, presence: true
  validates :correctable_type, inclusion: { in: ["CompatibilityNote", "InstallOrderNote", "InstallationNote", "Review"],
                                            message: "Not a valid record type that can contain incorrect notes"}



  def init
    self.created_at ||= DateTime.now
  end

  # Private Methods
  private
    # counter caches
    def increment_counter_caches
      if(self.correctable_type == "CompatibilityNote")
        self.correctable.incorrect_notes_count += 1
        self.correctable.save
      end
    end

    def decrement_counter_caches
      if(self.correctable_type == "CompatibilityNote")
        self.correctable.incorrect_notes_count -= 1
        self.correctable.save
      end
    end 
end
