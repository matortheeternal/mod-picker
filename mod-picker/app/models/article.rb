class Article < ActiveRecord::Base
  include Filterable, Sortable, Imageable, RecordEnhancements

  # SCOPES
  scope :text, -> (search) { where("text_body like ?", "%#{search}%") }
  scope :title, -> (search) { where("title like ?", "%#{search}%") }
  scope :submitter, -> (username) { joins(:submitter).where(:users => {:username => username}) }
  scope :submitted, -> (range) { where(submitted: parseDate(range[:min])..parseDate(range[:max])) }
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

  # number of users per page on the users index
  self.per_page = 15

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
