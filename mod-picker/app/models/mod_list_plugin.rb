class ModListPlugin < ActiveRecord::Base

  after_initialize :init

  after_create :increment_counter_caches
  before_destroy :decrement_counter_caches

  self.primary_keys = :mod_list_id, :plugin_id

  belongs_to :mod_list, :inverse_of => 'mod_list_plugins'
  belongs_to :plugin, :inverse_of => 'mod_list_plugins'

  # Validations
  validates :mod_list_id, :plugin_id, :index, presence: true
  validates :active, inclusion: [true, false]

  def init
    self.active ||= true
  end

  private
    # counter caches
    def increment_counter_caches
      self.mod_list.plugins_count += 1
      self.mod_list.save
    end

    def decrement_counter_caches
      self.mod_list.plugins_count -= 1
      self.mod_list.save
    end
end
