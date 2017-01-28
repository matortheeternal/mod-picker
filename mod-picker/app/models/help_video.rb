class HelpVideo < ActiveRecord::Base
  include RecordEnhancements, CounterCache, ScopeHelpers, BetterJson, Dateable, Approveable

  # ATTRIBUTES
  enum category: [:mod_picker, :modding, :guides]
  self.approval_method = :has_help_page_auto_approval?

  # DATE COLUMNS
  date_column :submitted, :edited

  # SCOPES
  game_scope
  search_scope :title, :text_body, :combine => true

  # ASSOCIATIONS
  belongs_to :submitter, :class_name => 'User', :foreign_key => 'submitted_by', :inverse_of => 'help_videos'
  belongs_to :game, :inverse_of => 'help_videos'

  has_many :help_video_sections, -> { where(parent_id: nil) }, inverse_of: "help_video", dependent: :destroy

  # COUNTER CACHE
  counter_cache_on :game

  # VALIDATIONS
  validates :title, :text_body, :category, presence: true
  validates :title, length: {in: 4..128}
  validates :text_body, length: {maximum: 16384}

  def url
    # TODO: This isn't properly reversible, need to just make string url_safe maybe?
    "Video:#{self.title.parameterize.underscore}"
  end
end
