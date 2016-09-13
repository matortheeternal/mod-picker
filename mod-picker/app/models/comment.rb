class Comment < ActiveRecord::Base
  include Filterable, Sortable, RecordEnhancements, Reportable, ScopeHelpers, Trackable

  # ATTRIBUTES
  self.per_page = 50

  # EVENT TRACKING
  track :added, :hidden

  # NOTIFICATION SUBSCRIPTIONS
  subscribe :commentable_user, to: [:added]
  subscribe :submitter, to: [:hidden, :unhidden]

  # SCOPES
  include_scope :hidden
  include_scope :parent_id, :alias => 'include_replies', :value => 'nil'
  search_scope :text_body, :alias => 'search'
  user_scope :submitter
  polymorphic_scope :commentable
  range_scope :children_count, :alias => 'replies'
  date_scope :submitted, :edited

  # ASSOCIATIONS
  belongs_to :submitter, :class_name => 'User', :foreign_key => 'submitted_by', :inverse_of => 'comments'
  belongs_to :commentable, :polymorphic => true

  # parent/child comment association
  belongs_to :parent, :class_name => 'Comment', :foreign_key => 'parent_id', :inverse_of => 'children'
  has_many :children, :class_name => 'Comment', :foreign_key => 'parent_id', :inverse_of => 'parent'

  # VALIDATIONS
  validates :submitted_by, :commentable_type, :commentable_id, :text_body, presence: true
  validates :hidden, inclusion: [true, false]
  validates :commentable_type, inclusion: ["User", "ModList", "Correction", "Article", "HelpPage"]
  validates :text_body, length: {in: 2..8192}
  validate :nesting

  # CALLBACKS
  before_save :set_dates
  after_create :increment_counter_caches
  before_destroy :decrement_counter_caches

  def nesting
    parent_id.nil? || parent.parent_id.nil?
  end

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

  def commentable_user
    case commentable_type
      when "Correction", "ModList", "Article"
        commentable.submitter
      when "User"
        commentable
      else
        nil
    end
  end

  def self.index_json(collection)
    collection.as_json({
        :except => :submitted_by,
        :include => {
            :submitter => {
                :only => [:id, :username, :role, :title],
                :include => {
                    :reputation => {:only => [:overall]}
                },
                :methods => :avatar
            }
        },
        :methods => :commentable_link
    })
  end

  def show_json
    as_json({
        :except => :submitted_by,
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
          :except => [:parent_id, :submitted_by],
          :include => {
              :submitter => {
                  :only => [:id, :username, :role, :title],
                  :include => {
                      :reputation => {:only => [:overall]}
                  },
                  :methods => :avatar
              },
              :children => {
                  :except => :submitted_by,
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

  def notification_json_options(event_type)
    options = {
        :only => [:commentable_type, :commentable_id],
        :include => {}
    }
    if commentable_type == "ModList"
      options[:include][:commentable] = { :only => [:name] }
    elsif commentable_type == "Correction"
      if commentable.correctable_type == "Mod"
        options[:include][:commentable] = {
            :only => [:mod_status],
            :include => {
                :correctable => { :only => [:id, :name] }
            }
        }
      else
        options[:include][:commentable] = {
            :only => [:correctable_id, :correctable_type, :title],
            :include => {
                :correctable => {
                    :only => [],
                    :include => {
                        :first_mod => { :only => [:id, :name] }
                    }
                }
            }
        }
      end
    end

    options
  end

  def self.sortable_columns
    {
        :except => [:parent_id, :submitted_by, :commentable_id, :text_body],
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
