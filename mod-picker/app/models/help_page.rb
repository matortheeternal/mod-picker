class HelpPage < ActiveRecord::Base
  include RecordEnhancements

  belongs_to :submitter, :class_name => 'User', :foreign_key => 'submitted_by', :inverse_of => 'help_pages'
  belongs_to :game, :inverse_of => 'help_pages'

  has_many :comments, :as => 'commentable'

  # enum for help page category
  enum category: [:mod_picker, :modding, :guides]

  # validations
  validates :title, :text_body, :category, presence: true
  validates :title, length: {in: 4..128}
  validates :text_body, length: {in: 64..32768}

  # Callbacks
  before_save :set_dates
  after_create :increment_counters
  before_destroy :decrement_counters

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
    self.title.parameterize.underscore
  end

  private
    def set_dates
      if self.submitted.nil?
        self.submitted = DateTime.now
      else
        self.edited = DateTime.now
      end
    end

    def decrement_counters
      self.game.update_counter(:help_pages_count, -1) if self.game_id.present?
    end

    def increment_counters
      self.game.update_counter(:help_pages_count, 1) if self.game_id.present?
    end
end
