class ModListCustomMod < ActiveRecord::Base
  include RecordEnhancements

  # Scopes
  scope :utility, -> (bool) { where(is_utility: bool) }

  # Associations
  belongs_to :mod_list, :inverse_of => 'custom_mods'

  # Validations
  validates :mod_list_id, :index, :name, presence: true
  validates :is_utility, inclusion: [true, false]
  validates :description, length: {maximum: 4096}

  # Callbacks
  after_create :increment_counters
  before_destroy :decrement_counters

  def as_json(options={})
    if JsonHelpers.json_options_empty(options)
      # TODO: Revise this as necessary
      default_options = {
          :except => [:mod_list_id]
      }
      super(options.merge(default_options))
    else
      super(options)
    end
  end

  private
    def increment_counters
      self.mod_list.update_counter(:custom_mods_count, 1)
    end

    def decrement_counters
      self.mod_list.update_counter(:custom_mods_count, -1)
    end
end
