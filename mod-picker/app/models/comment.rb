class Comment < ActiveRecord::Base
  include Filterable, Sortable, RecordEnhancements

  # BOOLEAN SCOPES (excludes content when false)
  scope :hidden, -> (bool) { where(hidden: false) if !bool  }
  scope :is_child, -> (bool) { where(parent_id: nil) if !bool }
  # GENERAL SCOPES
  scope :search, -> (text) { where("text_body like ?", "%#{text}%") }
  scope :submitter, -> (username) { joins(:submitter).where(:users => {:username => username}) }
  scope :commentable, -> (commentable_hash) {
    # build commentables array
    commentables = []
    commentable_hash.each_key do |key|
      if commentable_hash[key]
        commentables.push(key)
      end
    end

    # return query
    where(commentable_type: commentables)
  }
  # RANGE SCOPES
  scope :replies, -> (range) { where(children_count: range[:min]..range[:max]) }
  scope :submitted, -> (range) { where(submitted: parseDate(range[:min])..parseDate(range[:max])) }
  scope :edited, -> (range) { where(edited: parseDate(range[:min])..parseDate(range[:max])) }

  # ASSOCIATIONS
  belongs_to :submitter, :class_name => 'User', :foreign_key => 'submitted_by', :inverse_of => 'comments'
  belongs_to :commentable, :polymorphic => true

  has_one :base_report, :as => 'reportable'

  # parent/child comment association
  belongs_to :parent, :class_name => 'Comment', :foreign_key => 'parent_id', :inverse_of => 'children'
  has_many :children, :class_name => 'Comment', :foreign_key => 'parent_id', :inverse_of => 'parent'

  # number of comments per page on the comments index
  self.per_page = 50

  # Validations
  validates :submitted_by, :commentable_type, :commentable_id, :text_body, presence: true
  validates :hidden, inclusion: [true, false]
  validates :commentable_type, inclusion: ["User", "ModList", "Correction"]
  validates :text_body, length: {in: 2..8192}
  # TODO: Validation of nesting

  # Callbacks
  before_save :set_dates
  after_create :increment_counter_caches
  before_destroy :decrement_counter_caches

  def commentable_link
    if commentable_type == "Correction"
      if commentable.correctable_type == "Mod"
        "#/mods/" + commentable.correctable_id.to_s + "/appeals/" + commentable_id.to_s
      elsif commentable.correctable_type == "CompatibilityNote"
        "#/mods/compatibility/" + commentable.correctable_id.to_s + "/corrections/" + commentable_id.to_s
      elsif commentable.correctable_type == "InstallOrderNote"
        "#/mods/install-order/" + commentable.correctable_id.to_s + "/corrections/" + commentable_id.to_s
      elsif commentable.correctable_type == "LoadOrderNote"
        "#/mods/load-order/" + commentable.correctable_id.to_s + "/corrections/" + commentable_id.to_s
      end
    elsif commentable_type == "ModList"
      "#/mod-list/" + commentable_id.to_s
    elsif commentable_type == "User"
      "#/user/" + commentable_id.to_s
    end
  end

  def show_json
    as_json({
        :except => [:submitted_by, :commentable_id, :commentable_type],
        :include => {
            :submitter => {
                :only => [:id, :username, :role, :title],
                :include => {
                    :reputation => {:only => [:overall]}
                },
                :methods => :avatar
            }
        }
    })
  end

  def as_json(options={})
    if JsonHelpers.json_options_empty(options)
      default_options = {
          :except => [:parent_id, :submitted_by, :commentable_id, :commentable_type],
          :include => {
              :submitter => {
                  :only => [:id, :username, :role, :title],
                  :include => {
                      :reputation => {:only => [:overall]}
                  },
                  :methods => :avatar
              },
              :children => {
                  :except => [:submitted_by, :commentable_id, :commentable_type],
                  :include => {
                      :submitter => {
                          :only => [:id, :username, :role, :title],
                          :include => {
                              :reputation => {:only => [:overall]}
                          },
                          :methods => :avatar
                      },
                  }
              }
          }
      }
      super(options.merge(default_options))
    else
      super(options)
    end
  end

  # Private methods
  private
    def set_dates
      if self.submitted.nil?
        self.submitted = DateTime.now
      else
        self.edited = DateTime.now
      end
    end

    def increment_counter_caches
      self.submitter.update_counter(:submitted_comments_count, 1)
      self.commentable.update_counter(:comments_count, 1)
      if self.parent_id.present?
        self.parent.update_counter(:children_count, 1)
      end
    end

    def decrement_counter_caches
      self.submitter.update_counter(:submitted_comments_count, -1)
      self.commentable.update_counter(:comments_count, -1)
      if self.parent_id.present?
        self.parent.update_counter(:children_count, -1)
      end
    end

end
