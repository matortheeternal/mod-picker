class Mod < ActiveRecord::Base
  belongs_to :game
  belongs_to :primary_category, :class_name => 'Category', :foreign_key => 'category_id'
  belongs_to :secondary_category, :class_name => 'Category', :foreign_key => 'category_id'
  has_one :nexus_info
  has_one :lover_info
  has_one :workshop_info

  def as_json(options={})
    super(:include => [ :nexus_info, :lover_info, :workshop_info ])
  end
end
