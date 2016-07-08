class Comment < ActiveRecord::Base
  include Filterable, Sortable, RecordEnhancements

  scope :visible, -> { where(hidden: false) }
  scope :type, -> (type) { where(commentable_type: type) }
  scope :target, -> (id) { where(commentable_id: id) }
  scope :by, -> (id) { where(submitted_by: id) }

  belongs_to :submitter, :class_name => 'User', :foreign_key => 'submitted_by', :inverse_of => 'comments'
  belongs_to :commentable, :polymorphic => true

  has_one :base_report, :as => 'reportable'

  # parent/child comment association
  belongs_to :parent, :class_name => 'Comment', :foreign_key => 'parent_id', :inverse_of => 'children'
  has_many :children, :class_name => 'Comment', :foreign_key => 'parent_id', :inverse_of => 'parent'

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
