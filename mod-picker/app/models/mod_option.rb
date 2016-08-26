class ModOption < ActiveRecord::Base
  scope :default, -> { where(default: true) }

  belongs_to :mod, :inverse_of => 'mod_options'

  has_many :plugins, :inverse_of => 'mod_option'
  has_many :mod_asset_files, :inverse_of => 'mod_option'

  def update_counters
    self.asset_files_count = mod_asset_files.count
    self.plugins_count = plugins.count
    self.update_columns({
        plugins_count: plugins_count,
        asset_files_count: asset_files_count
    })
  end
end