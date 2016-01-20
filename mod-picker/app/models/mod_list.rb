class ModList < ActiveRecord::Base
  has_many :mods, :class_name => 'mod_list_mods'
  has_many :plugins, :class_name => 'mod_list_plugins'
  has_many :custom_plugins, :class_name => 'mod_list_custom_plugins', :inverse_of => 'mod_list'
  has_many :mod_list_compatibility_notes, :inverse_of => 'mod_list'
  has_many :compatibility_notes, :through => 'mod_list_compatibility_notes', :inverse_of => 'mod_lists'
  has_many :mod_list_installation_notes, :inverse_of => 'mod_list'
  has_many :installation_notes, :through => 'mod_list_installation_notes', :inverse_of => 'mod_lists'
  has_many :comments, :as => 'commentable', :through => 'mod_list_comments'
  belongs_to :game, :inverse_of => 'mod_lists'
end
