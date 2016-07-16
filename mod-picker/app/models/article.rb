class Article < ActiveRecord::Base
  include Imageable, RecordEnhancements

  belongs_to :submitter, :class_name => 'User', :foreign_key => 'submitted_by', :inverse_of => 'articles'

  # Validations
  validates :game_id, :submitted_by, :title, :text_body, presence: true

  # Callbacks
  before_save :set_dates

  def as_json(options={})
    if JsonHelpers.json_options_empty(options)
      default_options = {
          :include => {
              :submitter => {
                  :only => [:id, :username, :role, :title],
                  :methods => :avatar
              }
          },
          :methods => :image
      }
      super(options.merge(default_options))
    else
      super(options)
    end
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
