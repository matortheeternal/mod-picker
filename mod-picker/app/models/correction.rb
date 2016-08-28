class Correction < ActiveRecord::Base
  include Filterable, Sortable, RecordEnhancements, Reportable

  enum status: [:open, :passed, :failed, :closed]
  enum mod_status: [:good, :outdated, :unstable]

  # BOOLEAN SCOPES (excludes content when false)
  scope :include_hidden, -> (bool) { where(hidden: false) if !bool  }
  scope :include_adult, -> (bool) { where(has_adult_content: false) if !bool }
  # GENERAL SCOPES
  scope :visible, -> { where(hidden: false) }
  scope :game, -> (game_id) { where(game_id: game_id) }
  scope :search, -> (text) { where("corrections.title like ? OR corrections.text_body like ?", "%#{text}%", "%#{text}%") }
  scope :submitter, -> (username) { joins(:submitter).where(:users => {:username => username}) }
  scope :editor, -> (username) { joins(:editor).where(:users => {:username => username}) }
  scope :status, -> (statuses) {
    if statuses.is_a?(Hash)
      # handle hash search by building a statuses array
      statuses_array = []
      statuses.each_with_index do |(key,value),index|
        if statuses[key]
          statuses_array.push(index)
        end
      end
    else
      # else treat as an array of statuses
      statuses_array = statuses
    end

    # return query
    where(status: statuses_array)
  }
  scope :mod_status, -> (mod_statuses) {
    if mod_statuses.is_a?(Hash)
      # handle hash search by building a statuses array
      mod_statuses_array = []
      mod_statuses.each_with_index do |(key,value),index|
        if mod_statuses[key]
          mod_statuses_array.push(index)
        end
      end
    else
      # else treat as an array of statuses
      mod_statuses_array = mod_statuses
    end

    # return query
    where(mod_status: mod_statuses_array)
  }
  scope :correctable, -> (correctable_hash) {
    # build correctables array
    correctables = []
    correctable_hash.each_key do |key|
      if correctable_hash[key]
        correctables.push(key)
      end
    end

    # return query
    where(correctable_type: correctables)
  }
  # RANGE SCOPES
  scope :agree_count, -> (range) { where(agree_count: range[:min]..range[:max]) }
  scope :disagree_count, -> (range) { where(disagree_count: range[:min]..range[:max]) }
  scope :comments_count, -> (range) { where(comments_count: range[:min]..range[:max]) }
  scope :submitted, -> (range) { where(submitted: parseDate(range[:min])..parseDate(range[:max])) }
  scope :edited, -> (range) { where(edited: parseDate(range[:min])..parseDate(range[:max])) }

  belongs_to :game, :inverse_of => 'corrections'
  belongs_to :submitter, :class_name => 'User', :foreign_key => 'submitted_by', :inverse_of => 'corrections'
  belongs_to :editor, :class_name => 'User', :foreign_key => 'edited_by'

  has_many :agreement_marks, :inverse_of => 'correction'
  has_many :comments, -> { where(parent_id: nil) }, :as => 'commentable'
  
  belongs_to :correctable, :polymorphic => true

  # number of corrections per page on the corrections index
  self.per_page = 25

  # VALIDATIONS
  validates :game_id, :submitted_by, :correctable_id, :correctable_type, :text_body, presence: true
  validates :text_body, length: { in: 64..16384 }

  # CALLBACKS
  after_create :increment_counters, :schedule_close
  before_save :set_dates
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

    def schedule_close
      Correction.delay_for(1.week).close(id)
    end
end
