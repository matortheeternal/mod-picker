class ModList < ActiveRecord::Base
  belongs_to :game, :inverse_of => 'mod_lists'
  belongs_to :user, :foreign_key => 'created_by', :inverse_of => 'mod_lists'

  has_many :mods, :through => 'mod_list_mods', :inverse_of => 'mod_lists'
  has_many :mod_list_mods, :inverse_of => 'mod_list'
  has_many :plugins, :through => 'mod_list_plugins', :inverse_of => 'mod_lists'
  has_many :mod_list_plugins, :inverse_of => 'mod_list'
  has_many :custom_plugins, :class_name => 'ModListCustomPlugin', :inverse_of => 'mod_list'

  has_many :mod_list_compatibility_notes, :inverse_of => 'mod_list'
  has_many :compatibility_notes, :through => 'mod_list_compatibility_notes', :inverse_of => 'mod_lists'
  has_many :mod_list_installation_notes, :inverse_of => 'mod_list'
  has_many :installation_notes, :through => 'mod_list_installation_notes', :inverse_of => 'mod_lists'

  has_many :users_who_starred, :class_name => 'Users', :through => 'user_mod_list_star_maps', :inverse_of => 'starred_mod_lists'

  has_many :comments, :as => 'commentable', :through => 'mod_list_comments'
end
