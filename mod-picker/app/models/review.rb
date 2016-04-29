class Review < ActiveRecord::Base
  include Filterable

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

  def overall_rating
    total = self.rating1
    count = 1
    if self.rating2.present?
      total += self.rating2
      count += 1
    end
    if self.rating3.present?
      total += self.rating3
      count += 1
    end
    if self.rating4.present?
      total += self.rating4
      count += 1
    end
    if self.rating5.present?
      total += self.rating5
      count += 1
    end
    total / count
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
