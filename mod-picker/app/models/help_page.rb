class HelpPage < ActiveRecord::Base
  include RecordEnhancements

  # enum for help page category
  enum category: [:mod_picker, :modding, :guides]

  # scopes
  scope :game_long_name, -> (game_name) { joins(:game).where("games.long_name LIKE ?", "%#{game_name}%") }
  scope :title, -> (title) { where("title LIKE ?", "%#{title}%") }
  scope :text_body, -> (text_body) {  where("text_body LIKE ?", "%#{text_body}%") }
  scope :game, -> (game_id) { where(game_id: game_id) }

  # searches by title, text body, and category
  scope :search, -> (text) { where("title LIKE ? OR text_body LIKE ?",
             "%#{text}%", "%#{text}%"])}

  # associations
  belongs_to :submitter, :class_name => 'User', :foreign_key => 'submitted_by', :inverse_of => 'help_pages'
  belongs_to :game, :inverse_of => 'help_pages'

  has_many :comments, :as => 'commentable'

  # validations
  validates :title, :text_body, :category, presence: true
  validates :title, length: {in: 4..128}
  validates :text_body, length: {in: 64..32768}

  # Callbacks
  before_save :set_dates

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
end
