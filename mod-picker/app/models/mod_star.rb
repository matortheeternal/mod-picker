class ModStar < ActiveRecord::Base
  belongs_to :user_star, :class_name => 'User', :inverse_of => 'mod_stars'
  belongs_to :starred_mod, :class_name => 'Mod', :inverse_of => 'mod_stars'
end
