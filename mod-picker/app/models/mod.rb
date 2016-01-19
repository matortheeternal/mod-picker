class Mod < ActiveRecord::Base
  belongs_to :game, :inverse_of => 'mods'
  belongs_to :primary_category, :class_name => 'Category', :foreign_key => 'category_id', :inverse_of => 'primary_mods'
  belongs_to :secondary_category, :class_name => 'Category', :foreign_key => 'category_id', :inverse_of => 'secondary_mods'
  has_one :nexus_info
  has_one :lover_info
  has_one :workshop_info
  has_many :mod_versions
  has_many :reviews
  has_many :asset_files, :inverse_of => 'mod'
  has_many :comments, :as => 'commentable', :through => 'mod_comments'
end
