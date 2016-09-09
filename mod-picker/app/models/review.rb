class Review < ActiveRecord::Base
  include Filterable, Sortable, RecordEnhancements, Helpfulable, Reportable, ScopeHelpers

  # SCOPES
  include_scope :hidden
  include_scope :has_adult_content, :alias => 'include_adult'
  visible_scope :approvable => true
  game_scope
  search_scope :text_body, :alias => 'search'
  user_scope :submitter, :editor
  range_scope :overall_rating, :ratings_count
  date_scope :submitted, :edited

  # ASSOCIATIONS
  belongs_to :game, :inverse_of => 'reviews'
  belongs_to :submitter, :class_name => 'User', :foreign_key => 'submitted_by', :inverse_of => 'reviews'
  belongs_to :editor, :class_name => 'User', :foreign_key => 'edited_by'
  belongs_to :mod, :inverse_of => 'reviews'

  has_many :review_ratings, :inverse_of => 'review'

  accepts_nested_attributes_for :review_ratings

  self.per_page = 25

  # VALIDATIONS
  validates :game_id, :submitted_by, :mod_id, :text_body, presence: true
  validates :text_body, length: {in: 512..32768}
  # only one review per mod per user
  validates :mod_id, uniqueness: { scope: :submitted_by, :message => "You've already submitted a review for this mod." }

  # CALLBACKS
  after_create :increment_counters
  before_save :set_dates
  after_save :update_mod_metrics, :update_metrics
  before_destroy :clear_ratings, :decrement_counters

  def clear_ratings
    ReviewRating.where(review_id: self.id).delete_all
  end

  def update_metrics
    compute_overall_rating
    self.update_columns({
      ratings_count: self.review_ratings.count,
      overall_rating: self.overall_rating
    })
  end

  def update_mod_metrics
    self.mod.compute_average_rating
    self.mod.compute_reputation
    self.mod.save
  end

  def compute_overall_rating
    total = 0
    count = 0

    self.review_ratings.each do |r|
      total += r.rating
      count += 1
    end

    self.overall_rating = (total.to_f / count) if count > 0
  end

  def self.index_json(collection)
    collection.as_json({
        :include => {
            :review_ratings => {
                :except => [:review_id]
            },
            :submitter=> {
                :only => [:id, :username, :role, :title],
                :include => {
                    :reputation => {:only => [:overall]}
                },
                :methods => :avatar
            },
            :editor => {
                :only => [:id, :username, :role]
            },
            :mod => {
                :only => [:id, :name]
            }
        }
    })
  end
  
  def as_json(options={})
    if JsonHelpers.json_options_empty(options)
      default_options = {
          :include => {
              :review_ratings => {
                  :except => [:review_id]
              },
              :submitter => {
                  :only => [:id, :username, :role, :title],
                  :include => {
                      :reputation => {:only => [:overall]}
                  },
                  :methods => :avatar
              },
              :editor => {
                  :only => [:id, :username, :role]
              }
          }
      }
      super(options.merge(default_options))
    else
      super(options)
    end
  end

  def notification_json_options(event_type)
    {
        :only => [],
        :include => {
            :mod => { :only => [:id, :name] }
        }
    }
  end

  def self.sortable_columns
    {
        :except => [:game_id, :submitted_by, :edited_by, :mod_id, :text_body, :edit_summary, :moderator_message],
        :include => {
            :submitter => {
                :only => [:username],
                :include => {
                    :reputation => {
                        :only => [:overall]
                    }
                }
            }
        }
    }
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
      self.mod.reviews_count += 1
      self.mod.compute_average_rating
      # we also take this chance to recompute the mod's reputation
      # if there are enough reviews to do so
      if self.mod.reviews_count >= 5
        self.mod.compute_reputation
      end
      self.mod.save
      self.submitter.update_counter(:reviews_count, 1)
    end

    def decrement_counters
      self.mod.reviews_count -= 1
      self.mod.compute_average_rating
      self.mod.compute_reputation
      self.mod.save
      self.submitter.update_counter(:reviews_count, -1)
    end
end
