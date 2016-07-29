class Article < ActiveRecord::Base
  include Imageable, RecordEnhancements

  # SCOPES
  scope :game, -> (game_id) {
    # nil game_id means article is site-wide
    game = Game.find(game_id)
    if game.parent_game_id.present?
      where(game_id: [game.id, game.parent_game_id, nil])
    else
      where(game_id: [game.id, nil])
    end
  }

  # ASSOCIATIONS
  belongs_to :submitter, :class_name => 'User', :foreign_key => 'submitted_by', :inverse_of => 'articles'
  has_many :comments, :as => 'commentable'

  # VALIDATIONS
  validates :submitted_by, :title, :text_body, presence: true

  # CALLBACKS
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
