class ModListModOption < ActiveRecord::Base
  # ASSOCIATIONS
  belongs_to :mod_list_mod, :inverse_of => 'mod_list_mod_options'
  belongs_to :mod_option, :inverse_of => 'mod_list_mod_options'

  # VALIDATIONS
  validates :mod_list_id, :mod_option_id, presence: true
  validates :enabled, inclusion: [true, false]
end
