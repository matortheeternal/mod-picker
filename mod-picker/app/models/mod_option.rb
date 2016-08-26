class ModOption < ActiveRecord::Base
  belongs_to :mod, :inverse_of => 'mod_options'

  has_many :plugins, :inverse_of => 'mod_option'
  has_many :mod_asset_files, :inverse_of => 'mod_option'
end