class ConfigFile < ActiveRecord::Base
  include RecordEnhancements

  belongs_to :game, :inverse_of => 'config_files'
  belongs_to :mod, :inverse_of => 'config_files'
  has_many :mod_list_config_files, :inverse_of => 'config_file'

  # VALIDATIONS
  validates :game_id, :mod_id, :filename, :install_path, presence: true

  def as_json(options={})
    if JsonHelpers.json_options_empty(options)
      default_options = {
          :only => [:id, :filename]
      }
      super(options.merge(default_options))
    else
      super(options)
    end
  end
end
