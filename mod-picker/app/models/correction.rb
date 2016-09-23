class Correction < ActiveRecord::Base
  include Filterable, Sortable, RecordEnhancements, Reportable, ScopeHelpers, Trackable

  # ATTRIBUTES
  enum status: [:open, :passed, :failed, :closed]
  enum mod_status: [:good, :outdated, :unstable]
  self.per_page = 25

  # EVENT TRACKING
  track :added, :hidden, :status

  # NOTIFICATION SUBSCRIPTIONS
  subscribe :submitter, to: [:status, :action_soon, :hidden, :unhidden]
  subscribe :commenters, to: [:status]
  subscribe :mod_author_users, to: [:added, :status]

  # SCOPES
  include_scope :hidden
  include_scope :has_adult_content, :alias => 'include_adult'
  game_scope
  visible_scope
  search_scope :title, :text_body, :combine => true
  user_scope :submitter
  enum_scope :status
  enum_scope :mod_status
  polymorphic_scope :correctable
  range_scope :overall, :association => 'submitter_reputation', :table => 'user_reputations', :alias => 'reputation'

  # ASSOCIATIONS
  belongs_to :game, :inverse_of => 'corrections'
  belongs_to :submitter, :class_name => 'User', :foreign_key => 'submitted_by', :inverse_of => 'corrections'
  belongs_to :editor, :class_name => 'User', :foreign_key => 'edited_by'

  has_one :submitter_reputation, :class_name => 'UserReputation', :through => 'submitter', :source => 'reputation'

  has_many :agreement_marks, :inverse_of => 'correction'
  has_many :comments, -> { where(parent_id: nil) }, :as => 'commentable'
  has_many :commenters, :class_name => 'User', :through => :comments, :source => 'submitter'

  belongs_to :correctable, :polymorphic => true

  # VALIDATIONS
  validates :game_id, :submitted_by, :correctable_id, :correctable_type, :text_body, presence: true
  validates :text_body, length: { in: 64..16384 }

  # CALLBACKS
  after_create :increment_counters, :schedule_close
  before_save :set_adult, :set_dates
  after_save :recompute_correctable_standing
  after_destroy :decrement_counters, :recompute_correctable_standing

  def self.close(id)
    correction = Correction.find(id)
    if correction.status == :open
      if correction.agree_count > @correction.disagree_count
        correction.status = :passed
        # if we're dealing with a mod, update the mod's status
        if correction.correctable_type == 'Mod'
          mod = correction.correctable
          mod.update_columns(status: Mod.statuses[correction.mod_status])
        else
          # if we're dealing with a contribution, update its standing and open for editing
          contribution = correction.correctable
          contribution.update_columns({
              standing: contribution.class.standing[:bad],
              corrector_id: correction.submitted_by
          })
        end
      else
        correction.status = :failed
      end
      correction.save
    end
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

  def notification_json_options(event_type)
    is_appeal = correctable_type == "Mod"
    {
        :only => [:submitted_by, :correctable_type, :status, (:mod_status if is_appeal)].compact,
        :include => {
            :correctable => {
                :only => [:id, (:name if is_appeal)].compact,
                :methods => [(:mods if !is_appeal), (:plugins if correctable_type == "LoadOrderNote")].compact
            }
        }
    }
  end

  def reportable_json_options
    is_appeal = correctable_type == "Mod"
    {
        :only => [:submitted_by, :correctable_type, (:mod_status if is_appeal), :text_body, :submitted].compact,
        :include => {
            :correctable => {
                :only => [:id, (:name if is_appeal)].compact,
                :methods => [(:mods if !is_appeal), (:plugins if correctable_type == "LoadOrderNote")].compact
            },
            :submitter => {
                :only => [:id, :username, :role, :title],
                :include => {
                    :reputation => {:only => [:overall]}
                },
                :methods => :avatar
            }
        }
    }
  end

  def self.sortable_columns
    {
        :except => [:game_id, :submitted_by, :edited_by, :correctable_id, :text_body],
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

    def set_adult
      self.has_adult_content = correctable.has_adult_content
    end

    def increment_counters
      self.correctable.update_counter(:corrections_count, 1)
      self.submitter.update_counter(:corrections_count, 1)
    end

    def decrement_counters
      self.correctable.update_counter(:corrections_count, -1)
      self.submitter.update_counter(:corrections_count, -1)
    end

    def schedule_close
      Correction.delay_for(1.week).close(id)
    end
end
