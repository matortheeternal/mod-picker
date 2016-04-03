class ModListStar < ActiveRecord::Base
  self.primary_keys = :mod_list_id, :user_id

  belongs_to :user_star, :class_name => 'User', :inverse_of => 'mod_list_stars', :counter_cache => true
  belongs_to :starred_mod_list, :class_name => 'ModList', :inverse_of => 'mod_list_stars', :counter_cache => true
end
