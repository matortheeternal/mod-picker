class Category < ActiveRecord::Base
  include BetterJson

  # super/sub category associations
  belongs_to :parent, :class_name => 'Category', :foreign_key => 'parent_id', :inverse_of => 'sub_categories'
  has_many :sub_categories, :class_name => 'Category', :foreign_key => 'parent_id', :inverse_of => 'parent'

  # associations with category_priorities
  has_many :dominant_category_priorities, :class_name => 'CategoryPriority',:foreign_key => 'dominant_id', :dependent => :destroy
  has_many :recessive_category_priorities, :class_name => 'CategoryPriority',:foreign_key => 'recessive_id', :dependent => :destroy

  # review sections
  has_many :review_sections, :inverse_of => 'category', :dependent => :destroy

  # mods that are in this category
  has_many :primary_mods, :foreign_key => 'primary_category_id', :inverse_of => 'primary_category'
  has_many :secondary_mods, :foreign_key => 'secondary_category_id', :inverse_of => 'secondary_category'

  # VALIDATIONS
  validates :name, :description, presence: true

  # METHODS
  def self.read_chart
    file = File.read(Rails.root.join("db", "categories", "chart.json"))
    JSON.parse(file)
  end

  def self.chart
    @_chart ||= self.read_chart
  end
end
