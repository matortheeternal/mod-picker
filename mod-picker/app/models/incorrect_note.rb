class IncorrectNote < EnhancedRecord::Base
  include Filterable

  # Before/after actions for counter_caches
  after_create :increment_counter_caches
  before_destroy :decrement_counter_caches

  after_initialize :init   

  scope :by, -> (id) { where(submitted_by: id) }

  belongs_to :game, :inverse_of => 'incorrect_notes'
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
    # list of correctable_Types that have incorrect_notes_count counter cache
    COUNTER_CACHE_LIST = ["CompatibilityNote", "Review"]

    # counter caches
    # both iterate through the counter_cache list then break out of the loop
    # if a match is found after incrementing the incorrect_notes_count field of their 
    # correctable type
    def increment_counter_caches
      COUNTER_CACHE_LIST.each do |correct_type|
        if(self.correctable_type == correct_type)
          self.correctable.incorrect_notes_count += 1
          self.correctable.save
          break
        end
      end
    end

    def decrement_counter_caches
      COUNTER_CACHE_LIST.each do |correct_type|
        if(self.correctable_type == correct_type)
          self.correctable.incorrect_notes_count -= 1
          self.correctable.save
          break
        end
      end
    end 
end
