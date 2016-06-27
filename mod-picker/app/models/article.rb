class Article < ActiveRecord::Base
  belongs_to :user, :foreign_key => 'submitted_by', :inverse_of => 'articles'

  # Validations
  validates :game_id, :submitted_by, :title, :text_body, presence: true

  # Callbacks
  before_save :set_dates

  private
    def set_dates
      if self.submitted.nil?
        self.submitted = DateTime.now
      else
        self.edited = DateTime.now
      end
    end
end
