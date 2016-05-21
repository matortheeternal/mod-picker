class CategoryPriority < EnhancedRecord::Base
  self.primary_keys = :dominant_id, :recessive_id

  belongs_to :dominant_category, :class_name => 'Category', :foreign_key => 'category_id'
  belongs_to :recessive_category, :class_name => 'Category', :foreign_key => 'category_id'
end
