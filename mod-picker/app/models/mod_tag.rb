class ModTag < ActiveRecord::Base
  self.primary_keys = :mod_id, :tag_id

  belongs_to :mod, :inverse_of => 'mod_tags'
  belongs_to :tag, :inverse_of => 'mod_tags'
  belongs_to :user, :inverse_of => 'mod_tags'

  validates :game_id, :mod_id, :tag, presence: true
  validates :tag, length: {in: 2..32}
end
