class ModListGroup < ActiveRecord::Base
  enum tab: [:tools, :mods, :plugins]

  belongs_to :mod_list, :inverse_of => 'mod_list_groups'

  # Validations
  validates :mod_list_id, :name, presence: true

  def as_json(options={})
    if JsonHelpers.json_options_empty(options)
      default_options = {
          :only => [:id, :tab, :color, :name, :description]
      }
      super(options.merge(default_options))
    else
      super(options)
    end
  end
end
