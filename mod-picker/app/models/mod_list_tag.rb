class ModListTag < ActiveRecord::Base
  self.primary_keys = :mod_list_id, :tag_id

  belongs_to :mod_list, :inverse_of => 'mod_list_tags'
  belongs_to :tag, :inverse_of => 'mod_list_tags'
  belongs_to :user, :inverse_of => 'mod_list_tags'

  # Validations
  validates :tag, :game_id, :mod_list_id, presence: true
  validates :tag, length: {in: 2..32}
end
