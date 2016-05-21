class AssetFile < EnhancedRecord::Base
  belongs_to :game, :inverse_of => 'asset_files'

  has_many :mod_asset_files, :inverse_of => 'asset_file', :dependent => :destroy
  has_many :mods, :through => 'mod_asset_files', :inverse_of => 'asset_files'

  # Validations
  validates :filepath, presence: true

  def self.as_json(options={})
    if JsonHelpers.json_options_empty(options)
      default_options = {
          :only => [:filepath]
      }
      super(options.merge(default_options))
    else
      super(options)
    end
  end
end
