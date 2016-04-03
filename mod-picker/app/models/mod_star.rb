class ModStar < ActiveRecord::Base
  self.primary_keys = :mod_list_id, :user_id

  belongs_to :user, :inverse_of => 'mod_stars', :counter_cache => true
  belongs_to :mod, :inverse_of => 'mod_stars', :counter_cache => true
end
