class ModList < ActiveRecord::Base
  has_many :mods, :class_name => 'mod_list_mods'
  has_many :plugins, :class_name => 'mod_list_plugins'
  has_many :compatibility_notes, :class_name => 'mod_list_compatibility_notes'
  has_many :installation_notes, :class_name => 'mod_list_installation_notes'
  has_many :comments, :as => 'commentable', :through => 'mod_list_comments'
  belongs_to :game, :inverse_of => 'mod_lists'
end
