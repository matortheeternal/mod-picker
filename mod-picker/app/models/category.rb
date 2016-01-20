class Category < ActiveRecord::Base
  has_many :primary_mods, :foreign_key => 'primary_category_id', :inverse_of => 'primary_category'
  has_many :secondary_mods, :foreign_key => 'secondary_category_id', :inverse_of => 'secondary_category'
  belongs_to :parent, :class_name => 'Category', :foreign_key => 'parent_id', :inverse_of => 'sub_categories'
  has_many :sub_categories, :class_name => 'Category', :foreign_key => 'parent_id', :inverse_of => 'parent'
  has_many :dominant_categories, :class_name => 'Category', :through => 'category_priorities', :foreign_key => 'dominant_id'
  has_many :recessive_categories, :class_name => 'Category', :through => 'category_priorities', :foreign_key => 'recessive_id'
end
