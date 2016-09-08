class Event < ActiveRecord::Base
  include ScopeHelpers

  # We could save bandwidth by doing this on the frontend, if we wanted to
  enum event_type: [:added, :updated, :removed, :hidden, :unhidden, :approved, :unapproved, :status_changed, :action_soon, :message, :unused, :milestone1, :milestone2, :milestone3, :milestone4, :milestone5, :milestone6, :milestone7, :milestone8, :milestone9, :milestone10]

  # SCOPES
  enum_scope :event_type
  polymorphic_scope :content

  # ASSOCIATIONS
  belongs_to :content, :polymorphic => true
  has_many :read_notifications, :inverse_of => 'event'

  # number of events per page on the notifications index
  self.per_page = 50

  # VALIDATIONS
  validates :content_id, :content_type, :event_type, presence: true
  validates :content_type, length: {in: 1..32}

  # CALLBACKS
  before_create :set_dates

  def as_json(options={})
    if JsonHelpers.json_options_empty(options)
      content_keys = []
      content_methods = []
      content_include = {}

      case content_type
        when "Mod", "ModList"
          content_keys = [:name]
        when "User"
          content_keys = [:username]
          content_keys.push(:role) if event_type == :status_changed
        when "CompatibilityNote", "InstallOrderNote", "LoadOrderNote"
          content_keys = [:moderator_message] if event_type == :message
          content_methods = [:mods]
          content_methods.push(:plugins) if content_type == "LoadOrderNote"
        when "Review"
          content_include[:mod] = { :only => [:id, :name] }
        when "Correction"
          content_keys = [:correctable_type]
          content_keys.push(:status) if event_type == :status_changed

          if content.correctable_type == "Mod"
            content_keys.push(:mod_status)
            content_include[:correctable] = { :only => [:id, :name] }
          else
            correctable_methods = [:mods]
            if content.correctable_type == "LoadOrderNote"
              correctable_methods.push(:plugins)
            end

            content_include[:correctable] = {
                :only => [:id],
                :methods => correctable_methods
            }
          end
        when "ModTag"
          content_include[:tag] = { :only => [:text] }
          content_include[:mod] = { :only => [:id, :name] }
        when "ModListTag"
          content_include[:tag] = { :only => [:text] }
          content_include[:mod_list] = { :only => [:id, :name] }
        when "ModAuthor"
          content_keys = [:role]
          content_include[:mod] = { :only => [:id, :name] }
          content_include[:user] = { :only => [:id, :username] }
        when "ReputationLink"
          content_include[:target_user] = { :only => [:id, :username] }
          content_include[:source_user] = { :only => [:id, :username] }
        when "Comment"
          content_keys = [:commentable_type, :commentable_id]
          if content.commentable_type == "Correction"
            if content.commentable.correctable_type == "Mod"
              content_include[:commentable] = {
                  :only => [:mod_status],
                  :include => {
                      :mod => { :only => [:id, :name] }
                  }
              }
            else
              content_include[:commentable] = { :only => [:title] }
            end
          end
        when "NexusInfo", "LoverInfo", "WorkshopInfo"
          content_include[:mod] = { :only => [:id, :name] }
        when "Article"
          content_keys = [:title]
        when "Message"
          content_keys = [:text]
        else
          raise "Unhandled content type #{content_type}"
      end

      default_options = {
          :include => {
              :content => {
                  :only => content_keys,
                  :include => content_include,
                  :methods => content_methods
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
      self.created = DateTime.now
    end
end