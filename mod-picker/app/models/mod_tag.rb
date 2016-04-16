class ModTag < ActiveRecord::Base
  self.primary_keys = :mod_id, :tag_id

  belongs_to :mod, :inverse_of => 'mod_tags'
  belongs_to :tag, :inverse_of => 'mod_tags'
  belongs_to :user, :inverse_of => 'mod_tags'
end
