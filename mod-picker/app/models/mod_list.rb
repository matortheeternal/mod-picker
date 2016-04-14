class ModList < ActiveRecord::Base
  enum status: [ :planned, :"under construction", :testing, :complete ]

  belongs_to :game, :inverse_of => 'mod_lists'
  belongs_to :user, :foreign_key => 'created_by', :inverse_of => 'mod_lists'

  has_many :mods, :through => 'mod_list_mods', :inverse_of => 'mod_lists'
  has_many :mod_list_mods, :inverse_of => 'mod_list'
  has_many :plugins, :through => 'mod_list_plugins', :inverse_of => 'mod_lists'
  has_many :mod_list_plugins, :inverse_of => 'mod_list'
  has_many :custom_plugins, :class_name => 'ModListCustomPlugin', :inverse_of => 'mod_list'

  has_many :mod_list_compatibility_notes, :inverse_of => 'mod_list'
  has_many :compatibility_notes, :through => 'mod_list_compatibility_notes', :inverse_of => 'mod_lists'
  has_many :mod_list_install_order_notes, :inverse_of => 'mod_list'
  has_many :install_order_notes, :through => 'mod_list_install_order_notes', :inverse_of => 'mod_lists'
  has_many :mod_list_load_order_notes, :inverse_of => 'mod_list'
  has_many :load_order_notes, :through => 'mod_list_load_order_notes', :inverse_of => 'mod_lists'

  has_many :mod_list_stars, :inverse_of => 'starred_mod_list'
  has_many :user_stars, :through => 'mod_list_stars', :inverse_of => 'starred_mod_lists'

  has_many :comments, :as => 'commentable'
end
