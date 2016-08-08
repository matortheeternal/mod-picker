class HelpPage < ActiveRecord::Base
  include RecordEnhancements

  belongs_to :submitter, :class_name => 'User', :foreign_key => 'submitted_by', :inverse_of => 'help_pages'
  belongs_to :game, :inverse_of => 'help_pages'

  has_many :comments, :as => 'commentable'

  # enum for help page category
  enum category: [:mod_picker, :modding, :guides]

  # validations
  validates :name, :text_body, :category, presence: true
  validates :name, length: {in: 4..128}
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

  def url_name
    self.name.parameterize.underscore
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
