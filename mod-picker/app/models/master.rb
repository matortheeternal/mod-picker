class Master < ActiveRecord::Base
  self.primary_keys = :plugin_id, :master_plugin_id

  scope :plugins, -> (plugin_ids) { where(plugin_id: plugin_ids) }

  belongs_to :plugin, :inverse_of => 'masters'
  belongs_to :master_plugin, :class_name => 'Plugin', :foreign_key => 'master_plugin_id', :inverse_of => 'children'

  # VALIDATIONS
  validates :plugin_id, :master_plugin_id, :index, presence: true

  def as_json(options={})
    if JsonHelpers.json_options_empty(options)
      default_options = {
          :only => [],
          :include => {
              :plugin => {
                  :only => [:id, :mod_id, :filename]
              },
              :master_plugin => {
                  :only => [:id, :mod_id, :filename]
              }
          }
      }
      super(options.merge(default_options))
    else
      super(options)
    end
  end
end
