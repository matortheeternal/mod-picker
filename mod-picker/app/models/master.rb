class Master < ActiveRecord::Base
  belongs_to :plugin

  has_many :overrides, :class_name => 'OverrideRecord', :inverse_of => 'master'

  validates :plugin_id, :master_plugin_id, :index, presence: true
end
