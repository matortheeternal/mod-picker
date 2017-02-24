class HelpVideoSection < ActiveRecord::Base
  include RecordEnhancements,  BetterJson

  # ASSOCIATIONS
  belongs_to :help_video

  belongs_to :parent, class_name: "HelpVideoSection", foreign_key: "parent_id", inverse_of: "children"
  has_many :children, class_name: "HelpVideoSection", foreign_key: "parent_id", inverse_of: "parent"

  # VALIDATIONS
  validates :label, :seconds, presence: true
  validates :label, length: {in: 2..64}
  validates :description, length: {maximum: 255}
  validates :seconds, inclusion: { in: 0..86400 }
end
