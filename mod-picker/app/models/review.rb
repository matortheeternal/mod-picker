class Review < ActiveRecord::Base
  include Filterable

  after_initialize :init

  after_create :increment_counter_caches
  before_destroy :decrement_counter_caches

  scope :mod, -> (mod) { where(mod_id: mod) }
  scope :by, -> (id) { where(submitted_by: id) }

  belongs_to :user, :foreign_key => 'submitted_by', :inverse_of => 'reviews'
  
  belongs_to :mod, :inverse_of => 'reviews'
  belongs_to :review_template, :inverse_of => 'reviews'
  
  has_many :helpful_marks, :as => 'helpfulable'
  has_many :incorrect_notes, :as => 'correctable'
  has_one :base_report, :as => 'reportable'

  # Validations
  validates :review_template_id, :mod_id, :rating1, :text_body, presence: true
  validates :hidden, inclusion: [true, false]
  validates :rating1, :rating2, :rating3, :rating4, :rating5, length: {in: 0..100}
  validates :text_body, length: {in: 255..32768}

  # set values after being initialized
  def init
    self.hidden  ||= false
    self.rating1 ||= 0
    self.rating2 ||= 0
    self.rating3 ||= 0
    self.rating4 ||= 0
    self.rating5 ||= 0
    self.submitted ||= DateTime.now
  end

  private
    def increment_counter_caches
      self.mod.reviews_count += 1
      # we also take this chance to recompute the mod's reputation
      # if there are enough reviews to do so
      if self.mod.reviews_count >= 5
        self.mod.compute_reputation
      end
      self.mod.save
    end

    def decrement_counter_caches
      self.mod.reviews_count -= 1
      self.mod.save
    end
end
