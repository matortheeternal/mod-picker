class Article < ActiveRecord::Base
  include Filterable, Sortable, Imageable, RecordEnhancements, CounterCache, ScopeHelpers, Searchable, BetterJson, Dateable

  # ATTRIBUTES
  self.per_page = 15

  # DATE COLUMNS
  date_column :submitted, :edited

  # SCOPES
  date_scope :submitted

  # UNIQUE SCOPES
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
  has_many :comments, -> { where(parent_id: nil) }, :class_name => 'Comment', :as => 'commentable'

  # VALIDATIONS
  validates :submitted_by, :title, :text_body, presence: true
end
