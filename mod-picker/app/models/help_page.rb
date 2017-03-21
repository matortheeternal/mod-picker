class HelpPage < ActiveRecord::Base
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
  belongs_to :submitter, :class_name => 'User', :foreign_key => 'submitted_by', :inverse_of => 'help_pages'
  belongs_to :game, :inverse_of => 'help_pages'

  has_many :sections, -> { where(parent_id: nil) },  class_name: "HelpVideoSection", inverse_of: "help_page", dependent: :destroy

  has_many :comments, -> { where(parent_id: nil) }, :as => 'commentable'

  accepts_nested_attributes_for :sections, allow_destroy: true

  # COUNTER CACHE
  counter_cache_on :game

  # VALIDATIONS
  validates :title, :text_body, :category, presence: true
  validates :title, length: {in: 4..128}
  validates :text_body, length: {in: 64..32768}

  # show image banner via post id
  def display_image
    png_path = File.join(Rails.public_path, "help_pages/#{id}.png")
    jpg_path = File.join(Rails.public_path, "help_pages/#{id}.jpg")
    if File.exists?(png_path)
      "/help_pages/#{id}.png"
    elsif File.exists?(jpg_path)
      "/help_pages/#{id}.jpg"
    end
  end

  def url
    # TODO: This isn't properly reversible, need to just make string url_safe maybe?
    self.title.parameterize.underscore
  end
end
