class CategoryPriority < ActiveRecord::Base
  self.primary_keys = :dominant_id, :recessive_id

  belongs_to :dominant_category, :class_name => 'Category', :foreign_key => 'dominant_id'
  belongs_to :recessive_category, :class_name => 'Category', :foreign_key => 'recessive_id'

  # VALIDATIONS
  validates :dominant_id, :recessive_id, :description, presence: true
end
