class ModVersionFile < ActiveRecord::Base
  belongs_to :mod_version, :inverse_of => 'ModVersionFile'
  belongs_to :mod_asset_file, :inverse_of => 'ModVersionFile'
end
