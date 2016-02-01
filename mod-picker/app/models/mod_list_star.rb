class ModListStar < ActiveRecord::Base
  belongs_to :user_star, :class_name => 'User', :inverse_of => 'mod_list_stars'
  belongs_to :starred_mod_list, :class_name => 'ModList', :inverse_of => 'mod_list_stars'
end
