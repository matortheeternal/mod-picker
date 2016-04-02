class ModStar < ActiveRecord::Base
  belongs_to :user, :inverse_of => 'mod_stars', :counter_cache => true
  belongs_to :mod, :inverse_of => 'mod_stars', :counter_cache => true
end
