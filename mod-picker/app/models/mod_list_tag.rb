class ModListTag < EnhancedRecord::Base
  self.primary_keys = :mod_list_id, :tag_id

  belongs_to :mod_list, :inverse_of => 'mod_list_tags'
  belongs_to :tag, :inverse_of => 'mod_list_tags'
  belongs_to :user, :inverse_of => 'mod_list_tags'

  # Validations
  validates :tag, :mod_list_id, :submitted_by, presence: true
end
