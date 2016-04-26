class ModListMod < ActiveRecord::Base
  after_create :increment_counter_caches
  before_destroy :decrement_counter_caches

  after_initialize :init

  self.primary_keys = :mod_list_id, :mod_id

  belongs_to :mod_list, :inverse_of => 'mod_list_mods'
  belongs_to :mod, :inverse_of => 'mod_list_mods'

  validates :mod_list_id, :mod_id, :index, presence: true
  validates :active, inclusion: [true, false]

  def init
    self.active ||= true
  end

  private
    # counter caches
    def increment_counter_caches
      self.mod_list.mods_count += 1
      self.mod_list.save
    end

    def decrement_counter_caches
      self.mod_list.mods_count -= 1
      self.mod_list.save
    end
end
