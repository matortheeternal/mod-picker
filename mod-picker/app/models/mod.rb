class Mod < ActiveRecord::Base
  belongs_to :game
  belongs_to :primary_category, :class_name => 'Category', :foreign_key => 'category_id'
  belongs_to :secondary_category, :class_name => 'Category', :foreign_key => 'category_id'
end
