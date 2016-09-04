class AssetFile < ActiveRecord::Base
  include RecordEnhancements

  belongs_to :game, :inverse_of => 'asset_files'

  has_many :mod_asset_files, :inverse_of => 'asset_file', :dependent => :destroy
  has_many :mod_options, :through => 'mod_asset_files', :inverse_of => 'asset_files'

  # VALIDATIONS
  validates :game_id, :path, presence: true

  def as_json(options={})
    if JsonHelpers.json_options_empty(options)
      default_options = {
          :only => [:path]
      }
      super(options.merge(default_options))
    else
      super(options)
    end
  end
end
