class ModRequirement < ActiveRecord::Base
  include ScopeHelpers, BetterJson, CounterCache

  # SCOPES
  ids_scope :mod_id
  value_scope :is_utility, :association => 'required_mod', :table => 'mods'

  # UNIQUE SCOPES
  scope :visible, -> { eager_load(:required_mod, :mod).where(:mods => {:hidden => false}).where(:mods_mod_requirements => {:hidden => false}) }
  scope :mod_list, -> (mod_list_id) { joins("INNER JOIN mod_list_mods").where("mod_list_mods.mod_list_id = ?", mod_list_id).where("mod_requirements.mod_id = mod_list_mods.mod_id").distinct }

  # ASSOCIATIONS
  belongs_to :mod, :inverse_of => 'required_mods'
  belongs_to :required_mod, :class_name => 'Mod', :inverse_of => 'required_by', :foreign_key => 'required_id'

  # COUNTER CACHE
  counter_cache_on :mod, column: 'required_mods_count'
  counter_cache_on :required_mod, column: 'required_by_count'

  # VALIDATIONS
  validates :required_id, presence: true
  validates :required_id, uniqueness: { scope: :mod_id, :message => "Mod Requirement duplication is not allowed." }
end
