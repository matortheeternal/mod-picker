class Mod < ActiveRecord::Base
  belongs_to :game, :inverse_of => 'mods'

  belongs_to :primary_category, :class_name => 'Category', :foreign_key => 'category_id', :inverse_of => 'primary_mods'
  belongs_to :secondary_category, :class_name => 'Category', :foreign_key => 'category_id', :inverse_of => 'secondary_mods'

  has_one :nexus_info
  has_one :lover_info
  has_one :workshop_info

  has_many :mod_versions, :inverse_of => 'mod'

  has_many :mod_stars, :inverse_of => 'mod'
  has_many :users_who_starred, :class_name => 'User', :through => 'mod_stars', :inverse_of => 'starred_mods'
  has_many :mod_authors, :inverse_of => 'mod'
  has_many :authors, :through => 'mod_authors', :inverse_of => 'mods'

  has_many :reviews, :inverse_of => 'mod'
  has_many :comments, :as => 'commentable'
end
