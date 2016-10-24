class ModRequirement < ActiveRecord::Base
  include ScopeHelpers, BetterJson

  # SCOPES
  ids_scope :mod_id
  value_scope :is_utility, :association => 'required_mod', :table => 'mods'

  # UNIQUE SCOPES
  scope :visible, -> { eager_load(:required_mod, :mod).where(:mods => {:hidden => false}).where(:mods_mod_requirements => {:hidden => false}) }

  # ASSOCIATIONS
  belongs_to :mod, :inverse_of => 'required_mods'
  belongs_to :required_mod, :class_name => 'Mod', :inverse_of => 'required_by', :foreign_key => 'required_id'

  # VALIDATIONS
  validates :required_id, presence: true
  validates :required_id, uniqueness: { scope: :mod_id, :message => "Mod Requirement duplication is not allowed." }

  # CALLBACKS
  after_create :increment_counter_caches
  before_destroy :decrement_counter_caches

  # Private methods
  private
    def increment_counter_caches
      self.mod.update_counter(:required_mods_count, 1)
      self.required_mod.update_counter(:required_by_count, 1)
    end

    def decrement_counter_caches
      self.mod.update_counter(:required_mods_count, -1)
      self.required_mod.update_counter(:required_by_count, -1)
    end
end
