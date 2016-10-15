class ModListModOption < ActiveRecord::Base
  include ScopeHelpers, BetterJson

  # SCOPES
  scope :utility, -> (bool) { joins(:mod).where(:mods => {:is_utility => bool})}
  scope :official, -> (bool) { joins(:mod).where(:mods => {:is_official => bool})}

  # ASSOCIATIONS
  belongs_to :mod_list_mod, :inverse_of => 'mod_list_mod_options'
  belongs_to :mod_option, :inverse_of => 'mod_list_mod_options'

  has_one :mod, :through => :mod_list_mod

  # VALIDATIONS
  validates :mod_list_mod_id, :mod_option_id, presence: true
end
